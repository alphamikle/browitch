#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

rm -rf dist build/Browitch.xcarchive
mkdir -p dist build

xcodebuild \
  -project Browitch.xcodeproj \
  -scheme Browitch \
  -configuration Release \
  -destination 'generic/platform=macOS' \
  -derivedDataPath build/DerivedData \
  build

APP_PATH="$(find build/DerivedData/Build/Products/Release -maxdepth 1 -name 'Browitch.app' -type d -print -quit)"
if [[ -z "$APP_PATH" ]]; then
  echo "Browitch.app was not produced." >&2
  exit 1
fi

cp -R "$APP_PATH" dist/Browitch.app

xcodebuild \
  -project Browitch.xcodeproj \
  -scheme Browitch \
  -configuration Release \
  -destination 'generic/platform=macOS' \
  -archivePath build/Browitch.xcarchive \
  archive

echo "Built dist/Browitch.app"
echo "Archived build/Browitch.xcarchive"
