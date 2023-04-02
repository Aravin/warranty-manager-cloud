import * as functions from "firebase-functions/v2";

const {logger, https, scheduler} = functions;

export const health = https.onRequest((request, response) => {
  functions.logger.info("health api called!", {structuredData: true});
  response.send("Healthy");
});

export const weeklyjob = scheduler.onSchedule(
  "every sunday 08:00",
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