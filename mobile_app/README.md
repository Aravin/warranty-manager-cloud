# Warranty Manager

Warrant Manager Cloud - Manage all your bill/receipts/warranty of your product/services you purchased.

<img src="https://raw.githubusercontent.com/Aravin/warranty-manager-cloud/main/assets/readme_images/Screenshot_1679673987.png" height="400"><img src="https://user-images.githubusercontent.com/4869265/227573111-0fa5527a-a53a-4475-bac2-59e1f13779e3.png" height="400">





Introducing our new application: the Warranty Manager. This powerful tool allows you to easily manage all of your product warranties and related information. Whether you need to save, find, or track household, personal, or business assets, the Warranty Manager has you covered.

With our app, you can save a wide range of information about each product, including the product name, pricing, purchase date, warranty period, warranty start/end date, purchased location, company/brand name, salesperson name, email address and phone number for support, and notes for additional information.

We're always working to improve the app, and upcoming releases will include even more features, such as the ability to indicate whether a product has an international warranty, whether it was purchased online or offline, and the option to save bill copies and additional images.

Our roadmap includes plans to save all images related to each product, including the purchase bill, warranty bill, and additional images, so you can have everything in one convenient location. Additionally, you'll be able to track all service enquiries, repairs, or replacements for each product, making it easy to stay on top of everything.

For seamless access to your data across all devices and environments (mobile, desktop, web, etc.), we offer cloud syncing services.

We're always open to feedback and suggestions, so if you have any feature requests or comments, please let us know. We value your input and strive to address every question and concern. Thank you for choosing the Warranty Manager app!

---

## Firebase Cloud Messaging (FCM) & Push Notifications

This app natively integrates with FCM specifically to dispatch automatic push notifications exactly 7 days and 1 day before your saved products' warranties expire.

### Architecture Flow:
1. **Frontend Token Capture:** When a user logs into the app, the `HomeScreen` dynamically intercepts `FirebaseMessaging.instance.getToken()` directly off the device. This payload is stored locally and synchronized up into your Firestore `settings` collection.
2. **Backend Cron Dispatch:** The dispatching framework runs natively via Firebase Cloud Functions. Inside `backend/functions/src/index.ts`, there is a deployed schedule watcher called `sendWarrantyReminders` that automatically executes every single midnight globally (`00:00 UTC`).
3. **Trigger Evaluation:** The cron job exclusively targets users who still have `allowExpiryNotification == true`. It iterates over all active warranties tied to that user, calculates the Date distance, and commands the `firebase-admin/messaging` sdk to push an instant notification straight to their stored `fcmToken` if days remaining equals 7 or 1.
