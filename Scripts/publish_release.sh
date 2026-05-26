#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

VERSION="$(tr -d '[:space:]' < VERSION)"
TAG="v$VERSION"
VERSIONED_DMG="dist/Browitch-$VERSION.dmg"
LATEST_DMG="dist/Browitch.dmg"

if ! command -v gh >/dev/null 2>&1; then
  echo "GitHub CLI is required. Install it with: brew install gh" >&2
  exit 1
fi

if [[ ! -f "$VERSIONED_DMG" || ! -f "$LATEST_DMG" ]]; then
  echo "Expected $VERSIONED_DMG and $LATEST_DMG. Run Scripts/build_release.sh first." >&2
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "GitHub CLI is not authenticated. Run: gh auth login" >&2
  exit 1
fi

NOTES="$(cat <<EOF
Browitch $VERSION

First public release.

- Menu bar app for switching the macOS default browser.
- Lists installed HTTP/HTTPS browser handlers.
- Shows the current default browser with a checkmark.
- Supports Launch at Login.
- Ships as a DMG installer with drag-to-Applications layout.
EOF
)"

if gh release view "$TAG" >/dev/null 2>&1; then
  gh release upload "$TAG" "$VERSIONED_DMG" "$LATEST_DMG" --clobber
else
  gh release create "$TAG" "$VERSIONED_DMG" "$LATEST_DMG" \
    --title "Browitch $VERSION" \
    --notes "$NOTES"
fi

gh release view "$TAG" --web
