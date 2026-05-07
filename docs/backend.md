# Backend (Firebase Functions)

The `backend` directory contains custom backend logic hosted on Firebase Cloud Functions. The source code is specifically located in `backend/functions` and is written in TypeScript.

## Functions Breakdown

The main entry point for the backend is `backend/functions/src/index.ts`. It exports several cloud functions:

### HTTP Endpoints (API)
* **`health`**: A simple endpoint that responds with `"healthy"` to verify the API is running correctly.
* **`contact`**: A POST endpoint used to submit contact requests or support tickets. It authenticates the user via their Bearer token and sends an email via SendGrid.
  * **Required Environment Variables**:
    * `SENDGRID_API_KEY`: API key for SendGrid authentication.
    * `SENDGRID_FROM_EMAIL` (Optional): The sending email address.
    * `CONTACT_TO_EMAIL` (Optional): The recipient email address for support tickets.

### Scheduled Tasks (Cron Jobs)
* **`cleanupAnonymousUser`**: Runs on the 1st of every month (`0 0 1 * *`). It finds inactive anonymous users (inactive for more than 90 days) and deletes all their saved warranties and settings to save database space.
* **`sendWarrantyReminders`**: Runs daily at midnight UTC (`0 0 * * *`). It scans for warranties expiring in exactly 7 days or 1 day for users who have opted into push notifications, and triggers an FCM push notification alert.

## Commands

Before running any commands, make sure you are inside the `backend/functions` directory:
```bash
cd backend/functions
```

### Fetch Dependencies
```bash
npm install
# or
npm ci
```

### Linting
To check for syntax and style issues:
```bash
npm run lint
```

### Building
To compile TypeScript source files into JavaScript for deployment:
```bash
npm run build
```
