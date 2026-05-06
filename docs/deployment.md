# Deployment & CI/CD

Warranty Manager Cloud uses an automated pipeline for continuous integration and offers custom scripts for release builds.

## Continuous Integration (CI)

The CI pipeline is orchestrated via GitHub Actions and is configured in `.github/workflows/pipeline.yml`. It runs automatically on pull requests and pushes to the `main` branch.

### Pipeline Logic
1. **Changes Detection**: The pipeline first checks which directory was modified (`mobile_app/`, `backend/`, or the pipeline script itself).
2. **Frontend Job**: If `mobile_app` changes are detected, it runs the `flutter` job.
   * Runs `flutter pub get`.
   * Runs `flutter analyze`.
   * Runs `flutter test`.
3. **Backend Job**: If `backend` changes are detected, it runs the `firebase-functions` job using Node.js 22.
   * Runs `npm ci`.
   * Runs `npm run lint`.
   * Runs `npm run build`.

## Release Build Script

For manual or automated Android app bundle releases, there is a custom bash script located at `mobile_app/scripts/build.sh`.

### What it does:
1. **Version Bumping**: It reads the current version from `pubspec.yaml`. It splits the semantic version and the build number (e.g., `1.0.0+5`). It increments the build number natively, or overriding it if `GITHUB_RUN_NUMBER` is present.
2. **Update Metadata**: It uses `sed` to update `pubspec.yaml` with the newly incremented build version.
3. **Clean & Build**: It runs `flutter clean`, `flutter pub get`, and finally `flutter build appbundle --release` to generate the AAB file suitable for Google Play Console upload.

## Android Keystore (Signing)

For Android release signing, `build.gradle` expects a `key.properties` file located at `mobile_app/android/key.properties`.

* **Important Pathing Note**: The actual keystore file path defined inside `key.properties` is resolved relative to the `app` module directory (e.g., if you specify `upload-keystore.jks` in the properties, the system expects the file to be located at `mobile_app/android/app/upload-keystore.jks`).
