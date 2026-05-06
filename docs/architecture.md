# System Architecture

The Warranty Manager Cloud application adopts a serverless backend-as-a-service (BaaS) architecture with a cross-platform frontend client.

## Core Components

### 1. Frontend Client
* **Framework**: Flutter.
* **Platforms**: iOS and Android (with preliminary configuration for Desktop/Web).
* **Responsibility**: Provides the user interface, manages local UI state, intercepts and captures the device's FCM token, and interfaces with Firebase.

### 2. Backend Services (Firebase)
* **Authentication (`firebase_auth`)**: Handles user sign-up and login natively (e.g., Google, Facebook, Apple, and Email authentication). Also supports Anonymous sign-ins.
* **Database (`cloud_firestore`)**: A NoSQL cloud database storing user settings, product warranties, and notifications. Rules are used to isolate user data based on their UID.
* **Storage (`firebase_storage`)**: Used to store user uploads, such as receipt/invoice images or product photos.
* **Analytics & Performance (`firebase_analytics`, `firebase_performance`)**: Tracks usage analytics and monitors application performance.
* **Crashlytics (`firebase_crashlytics`)**: Monitors runtime errors and fatal crashes on the mobile app.

### 3. Custom Backend Logic (Firebase Functions)
Located in `backend/functions`, these Node.js/TypeScript functions extend Firebase capabilities:
* **Background Tasks (Cron Jobs)**:
  * Running scheduled functions (via Cloud Scheduler) to automatically check for warranties about to expire.
  * Running cleanup processes to remove unneeded data (e.g., removing inactive anonymous users).
* **HTTP Endpoints**:
  * Handling logic such as sending emails via SendGrid (`/contact` API).

## Push Notifications Flow (FCM)
The application relies heavily on Push Notifications to alert users about their expiring warranties.
1. **Token Capture**: When a user logs in, the home screen retrieves the device's FCM token using `FirebaseMessaging.instance.getToken()`.
2. **Database Sync**: The token is saved to the user's `settings` document in Firestore.
3. **Dispatch**: A Firebase Scheduled Function (`sendWarrantyReminders`) runs daily at 00:00 UTC. It checks if the user has `allowExpiryNotification == true`, scans their active warranties, and pushes an instant notification directly to the `fcmToken` if there are 7 days or 1 day left until expiry.
