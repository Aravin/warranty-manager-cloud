#!/bin/bash

# Navigate to the mobile app directory
cd "/Users/aravind_appadurai/personal-projects/android-apps/warranty-manager-cloud/mobile_app" || exit 1

echo "🔍 Reading current version from pubspec.yaml..."
CURRENT_VERSION=$(grep "^version: " pubspec.yaml | sed 's/version: //')
echo "📦 Current version: $CURRENT_VERSION"

# Use Perl to increment the PATCH version and the BUILD number
# Example: 4.0.0+125 -> 4.0.1+126
# If you instead want to increment the MINOR version (4.1.0+126), change ($3+1) to 0 and ($2+1) instead of $2 below:
perl -i -pe 's/version: (\d+)\.(\d+)\.(\d+)\+(\d+)/"version: $1.$2.".($3+1)."+".($4+1)/e' pubspec.yaml

NEW_VERSION=$(grep "^version: " pubspec.yaml | sed 's/version: //')
echo "🚀 Bumped version to: $NEW_VERSION"

echo "🧹 Cleaning project..."
flutter clean
flutter pub get

echo "🔨 Building AppBundle (.aab)..."
flutter build appbundle --release

echo "🔨 Building APK (.apk)..."
flutter build apk --release

echo "✅ Build successfully completed for version $NEW_VERSION!"
echo "📍 APK Location: $(pwd)/build/app/outputs/flutter-apk/app-release.apk"
echo "📍 AAB Location: $(pwd)/build/app/outputs/bundle/release/app-release.aab"
