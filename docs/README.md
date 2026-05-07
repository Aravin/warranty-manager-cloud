# Warranty Manager Cloud Documentation

Welcome to the documentation for **Warranty Manager Cloud** - an application to manage all your bill/receipts/warranties of your product/services you purchased.

## Project Overview

The repository is logically separated into two primary directories:

* **`mobile_app/`**: Contains the source code for the mobile application. It is a Flutter application that runs on multiple platforms (primarily iOS and Android).
* **`backend/`**: Contains the source code for the backend API and background tasks. It consists of Firebase Functions written in Node.js and TypeScript.

## Documentation Index

The following detailed documentation files are available:

1. **[System Architecture](architecture.md)**: An overview of how the frontend and backend systems interact, including core services like Firebase Auth, Firestore, Crashlytics, and Push Notifications via FCM.
2. **[Frontend (Mobile App)](frontend.md)**: Detailed information about the Flutter mobile application, state management, UI implementation caveats (like `flutter_form_builder`), and local testing/linting instructions.
3. **[Backend (Firebase Functions)](backend.md)**: Detailed information about the Firebase Cloud Functions, scheduled cron jobs, and API endpoints.
4. **[Deployment & CI/CD](deployment.md)**: A guide to the deployment process, continuous integration pipeline (GitHub Actions), and build scripts for release.
