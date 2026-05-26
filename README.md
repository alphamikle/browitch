# Browitch

Browitch is a tiny native macOS menu bar app for switching the default browser in one click.

Current version: `1.0.0`.

## Download

Download the latest installer from GitHub Releases:

- [Browitch.dmg](https://github.com/alphamikle/browitch/releases/latest/download/Browitch.dmg)
- [All releases](https://github.com/alphamikle/browitch/releases)

Open the DMG, then drag `Browitch.app` into `Applications`. Browitch will then appear in the installed apps list. Launching it from Applications shows a small toast and keeps the app running in the menu bar.

## Requirements

- macOS 26 or newer
- Xcode 26 or newer
- Homebrew, only if you want to install `gh` for publishing releases

## Run from Xcode

Open `Browitch.xcodeproj`, select the `Browitch` scheme, then run.

The app is `LSUIElement`-only, so it appears in the menu bar and does not show a Dock icon.

## Build Locally

```sh
Scripts/build_release.sh
```

The script creates:

- `dist/Browitch.app`
- `dist/Browitch.dmg`
- `dist/Browitch-1.0.0.dmg`
- `build/Browitch.xcarchive`

## Publish a GitHub Release

Install and authenticate GitHub CLI:

```sh
brew install gh
gh auth login
```

Then build and publish the release assets:

```sh
Scripts/build_release.sh
Scripts/publish_release.sh
```

`Scripts/publish_release.sh` creates or updates the `v1.0.0` GitHub Release and uploads both `Browitch-1.0.0.dmg` and `Browitch.dmg`.

## Behavior

- The menu lists apps registered as handlers for both `http` and `https`.
- The current default browser is shown with a checkmark.
- Selecting another browser sets it as the default for both `http` and `https`.
- `Launch at Login` uses `SMAppService.mainApp`.

macOS may still show a system confirmation prompt when changing the default browser. Browitch asks LaunchServices to switch immediately; any confirmation is controlled by macOS.
