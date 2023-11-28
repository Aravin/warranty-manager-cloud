import { initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import * as functions from "firebase-functions/v2";

const { logger, https, scheduler } = functions;
initializeApp();
const db = getFirestore();

export const health = https.onRequest(async (request, response) => {
  functions.logger.info("health api called!", { structuredData: true });
  response.send('healthy');
});

export const weeklyjob = scheduler.onSchedule(
  "every sunday 08:00",
  async (event) => {
    const snapshot = await db.collection("warranty").get();

    for (const doc of snapshot.docs) {
      // console.log(doc.id, "=>", doc.data());
    }

    logger.log("User cleanup finished");
  });

export const dailyjob = scheduler.onSchedule(
  "every day 08:00",
  async (event) => {
    // Fetch all user details.
    // const inactiveUsers = await getInactiveUsers();

    // Use a pool so that we delete maximum `MAX_CONCURRENT` users in parallel.
    // const promisePool = new PromisePool(
    //     () => deleteInactiveUser(inactiveUsers),
    //     MAX_CONCURRENT,
    // );
    // await promisePool.start();
    logger.log("User cleanup finished");
  });

export const test = https.onRequest(async (request, response) => {
  functions.logger.info("health api called!", { structuredData: true });
  const snapshot = await db.collection("warranty").get();

  for (const doc of snapshot.docs) {
    // console.log(doc.id, "=>", doc.data());
  }
});