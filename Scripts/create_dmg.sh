#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

APP_PATH="dist/Browitch.app"
DMG_STAGING="build/dmg/Browitch"
VERSION="$(tr -d '[:space:]' < VERSION)"
VERSIONED_DMG_PATH="dist/Browitch-$VERSION.dmg"
LATEST_DMG_PATH="dist/Browitch.dmg"

if [[ ! -d "$APP_PATH" ]]; then
  echo "Expected $APP_PATH. Run Scripts/build_release.sh first." >&2
  exit 1
fi

rm -rf "$DMG_STAGING" "$VERSIONED_DMG_PATH" "$LATEST_DMG_PATH"
mkdir -p "$DMG_STAGING"

cp -R "$APP_PATH" "$DMG_STAGING/Browitch.app"
ln -s /Applications "$DMG_STAGING/Applications"

hdiutil create \
  -volname "Browitch $VERSION" \
  -srcfolder "$DMG_STAGING" \
  -ov \
  -format UDZO \
  "$VERSIONED_DMG_PATH"

cp "$VERSIONED_DMG_PATH" "$LATEST_DMG_PATH"

echo "Created $VERSIONED_DMG_PATH"
echo "Created $LATEST_DMG_PATH"
