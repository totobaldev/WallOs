#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DIR="$ROOT_DIR/apps/desktop_flutter"
ARCHIVE_PATH="$APP_DIR/build/macos/archive/WallOs.xcarchive"

printf "[1/3] Sync wallpapers...\n"
node "$ROOT_DIR/scripts/sync_flutter_wallpapers.mjs"

printf "[2/3] Build Flutter macOS release...\n"
cd "$APP_DIR"
flutter build macos --release

printf "[3/3] Create Xcode archive...\n"
cd "$APP_DIR/macos"
xcodebuild \
  -workspace Runner.xcworkspace \
  -scheme Runner \
  -configuration Release \
  -archivePath "$ARCHIVE_PATH" \
  archive

printf "\nArchive ready at:\n%s\n" "$ARCHIVE_PATH"
printf "Next: open Xcode Organizer and upload to App Store Connect.\n"
