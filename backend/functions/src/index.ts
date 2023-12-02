import {logger} from 'firebase-functions';
import {onRequest} from 'firebase-functions/v2/https';
import { } from 'firebase-functions/v2/firestore';
import {onSchedule} from 'firebase-functions/v2/scheduler';

import {ServiceAccount, initializeApp} from 'firebase-admin/app';
import {Timestamp, getFirestore} from 'firebase-admin/firestore';
import {credential} from 'firebase-admin';

import serviceAccount = require('./firebase_service_account_key.json');
import { setGlobalOptions } from 'firebase-functions/v2/options';

initializeApp({
  credential: credential.cert(serviceAccount as ServiceAccount),
});
const db = getFirestore();
setGlobalOptions({ maxInstances: 10 });

export const health = onRequest(async (request, response) => {
  logger.info('health api called!', {structuredData: true});
  response.send('healthy');
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
