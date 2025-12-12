#!/bin/bash

# Define the file path
PUBSPEC_FILE="pubspec.yaml"

# Check if pubspec.yaml exists
if [ ! -f "$PUBSPEC_FILE" ]; then
  echo "Error: $PUBSPEC_FILE not found!"
  exit 1
fi

# Extract the current version line
VERSION_LINE=$(grep '^version: ' "$PUBSPEC_FILE")

# Extract the version number (everything after 'version: ')
CURRENT_VERSION=$(echo "$VERSION_LINE" | sed 's/^version: //')

# Split the version into base (x.y.z) and build number (n)
BASE_VERSION=$(echo "$CURRENT_VERSION" | cut -d'+' -f1)
BUILD_NUMBER=$(echo "$CURRENT_VERSION" | cut -d'+' -f2)

# Increment the build number
NEW_BUILD_NUMBER=$((BUILD_NUMBER + 1))

# Construct the new version string
NEW_VERSION="$BASE_VERSION+$NEW_BUILD_NUMBER"

# Update pubspec.yaml with the new version
# Use a temporary file to handle differences between sed on macOS and Linux
sed "s/^version: .*/version: $NEW_VERSION/" "$PUBSPEC_FILE" > "${PUBSPEC_FILE}.tmp" && mv "${PUBSPEC_FILE}.tmp" "$PUBSPEC_FILE"

echo "Updated version from $CURRENT_VERSION to $NEW_VERSION"

# Run the Flutter build command
echo "Running flutter build appbundle..."
flutter build appbundle
