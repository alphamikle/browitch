# Browitch

Browitch is a tiny native macOS menu bar app for switching the default browser in one click.

## Requirements

- macOS 26 or newer
- Xcode 26 or newer

## Run from Xcode

Open `Browitch.xcodeproj`, select the `Browitch` scheme, then run.

The app is `LSUIElement`-only, so it appears in the menu bar and does not show a Dock icon.

## Build Locally

```sh
Scripts/build_release.sh
```

The script creates:

- `dist/Browitch.app`
- `build/Browitch.xcarchive`

## Behavior

- The menu lists apps registered as handlers for both `http` and `https`.
- The current default browser is shown with a checkmark.
- Selecting another browser sets it as the default for both `http` and `https`.
- `Launch at Login` uses `SMAppService.mainApp`.

macOS may still show a system confirmation prompt when changing the default browser. Browitch asks LaunchServices to switch immediately; any confirmation is controlled by macOS.
