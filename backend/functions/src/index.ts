import * as dotenv from 'dotenv';
import * as sgMail from '@sendgrid/mail';
import {logger} from 'firebase-functions';
import {HttpsError, onRequest} from 'firebase-functions/v2/https';
import { } from 'firebase-functions/v2/firestore';
import {onSchedule} from 'firebase-functions/v2/scheduler';

import {initializeApp} from 'firebase-admin/app';
import {Timestamp, getFirestore} from 'firebase-admin/firestore';
import {getAuth} from 'firebase-admin/auth';
import { setGlobalOptions } from 'firebase-functions/v2/options';

dotenv.config();

const sendGridApiKey = process.env.SENDGRID_API_KEY;
const sendGridFromEmail =
  process.env.SENDGRID_FROM_EMAIL || 'warranty-manager@exaful.com';
const contactToEmail = process.env.CONTACT_TO_EMAIL || 'aravin.it@gmail.com';

if (sendGridApiKey) {
  sgMail.setApiKey(sendGridApiKey);
}

initializeApp();
const db = getFirestore();
setGlobalOptions({ maxInstances: 10 });

function getBearerToken(authorizationHeader?: string): string | null {
  if (!authorizationHeader?.startsWith('Bearer ')) {
    return null;
  }

  return authorizationHeader.substring('Bearer '.length).trim();
}

export const health = onRequest(async (request, response) => {
  logger.info('health api called!', {structuredData: true});
  response.send('healthy');
});

export const contact = onRequest(async (request, response) => {
  response.set('Access-Control-Allow-Origin', '*');
  response.set('Access-Control-Allow-Headers', 'Authorization, Content-Type');
  response.set('Access-Control-Allow-Methods', 'POST, OPTIONS');

  if (request.method === 'OPTIONS') {
    response.status(204).send('');
    return;
  }

  if (request.method !== 'POST') {
    response.status(405).json({error: 'method-not-allowed'});
    return;
  }

  if (!sendGridApiKey) {
    logger.error('SENDGRID_API_KEY is not configured');
    response.status(500).json({error: 'mail-service-not-configured'});
    return;
  }

  try {
    const idToken = getBearerToken(request.headers.authorization);
    if (!idToken) {
      throw new HttpsError('unauthenticated', 'Missing authorization token');
    }

    const decodedToken = await getAuth().verifyIdToken(idToken);
    const message = typeof request.body?.message === 'string'
      ? request.body.message.trim()
      : '';
    const reason = typeof request.body?.reason === 'string'
      ? request.body.reason.trim()
      : '';
    const version = typeof request.body?.version === 'string'
      ? request.body.version.trim()
      : 'unknown';
    const buildNumber = typeof request.body?.buildNumber === 'string'
      ? request.body.buildNumber.trim()
      : 'unknown';

    if (!message || !reason) {
      throw new HttpsError('invalid-argument', 'Reason and message are required');
    }

    await sgMail.send({
      to: contactToEmail,
      from: {
        email: sendGridFromEmail,
        name: 'Warranty Manager',
      },
      subject: `${reason} from Warranty Manager Cloud`,
      text: [
        `Reason: ${reason}`,
        `User: ${decodedToken.email || decodedToken.uid}`,
        `UID: ${decodedToken.uid}`,
        `Version: ${version}`,
        `Build: ${buildNumber}`,
        '',
        message,
      ].join('\n'),
    });

    response.status(202).json({ok: true});
  } catch (error) {
    if (error instanceof HttpsError) {
      logger.warn('Rejected contact request', {message: error.message});
      response.status(error.httpErrorCode.status).json({error: error.code});
      return;
    }

    logger.error('Failed to send contact email', error as Error);
    response.status(500).json({error: 'internal'});
  }
});

// during test wrongly removed all settings
export const cleanupAnonymousUser = onSchedule(
  '0 0 1 * *',
  async (event) => {
    logger.log('cleanupAnonymousUser Service called', event);

    try {
      logger.log('Getting all the user settings');

      const settingsSnapshot = await db.collection('settings').get();
      let inactiveAnonymousUserCount = 0;

      logger.log('Looping all the settings to filter and remove inactive users');

      for (const doc of settingsSnapshot.docs) {
        logger.log(`Processing ${doc.id}`);

        const isAnonymous = doc.data()['isAnonymous'];
        const lastSignInTime = (doc.data()['lastSignInTime'] as Timestamp).toDate();
        const diffInDays = (lastSignInTime.getTime() - new Date().getTime()) / (1000 * 60 * 60 * 24);

        if (isAnonymous && (-diffInDays > 90)) {
          logger.log(`isAnonymous and Inactive user found ${doc.id}, deleting all warranties`);
          inactiveAnonymousUserCount++;
          const warrantySnapshot =
            await db.collection('warranty').where('userId', '==', doc.id).get();

          // delete all saved warranties
          for (const warrantyDoc of warrantySnapshot.docs) {
            await db.collection('warranty').doc(warrantyDoc.id).delete();
          }

          // delete user settings
          logger.log(`deleting ${doc.id} settings`);
          await db.collection('settings').doc(doc.id).delete();
        } else {
          logger.log(`Not isAnonymous or Not exceed the inactive period ${doc.id}`);
        }
      }

      logger.log(`Total inactive Anonymous used removed ${inactiveAnonymousUserCount}`);
    } catch (err) {
      logger.error(err as Error);
    }
  });
