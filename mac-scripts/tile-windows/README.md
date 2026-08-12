# Tile Two Windows (macOS)

Tiles the **current window** and the **previous window** side by side on the main screen with a single click (or `Cmd+Ctrl+T`).

Uses [Hammerspoon](https://www.hammerspoon.org) for window management via the macOS Accessibility API.

## Files

| File | Purpose |
|---|---|
| `hammerspoon-init.lua` | Hammerspoon config with the tiling logic |
| `tile-windows.applescript` | Clickable `.app` source that triggers tiling via Hammerspoon IPC |

## Setup (on your macOS machine)

### 1. Install Hammerspoon
```bash
brew install --cask hammerspoon
```
Open Hammerspoon and **grant Accessibility permission** in System Settings → Privacy & Security → Accessibility.

### 2. Install the config
```bash
# Back up existing config if you have one
cp ~/.hammerspoon/init.lua ~/.hammerspoon/init.lua.bak 2>/dev/null

# Copy our tiling config in
cp hammerspoon-init.lua ~/.hammerspoon/init.lua

# Reload
hs -c "hs.reload()"
# OR: click the Hammerspoon menubar icon → Reload All
```

### 3. Enable IPC Server
- Hammerspoon → Preferences → check **"Enable CLI (IPC Server)"**
- This registers the `hs` command so the AppleScript can invoke it.

### 4. (Optional) Build the clickable app
```bash
# From this directory:
osacompile -o ~/Applications/Tile\ Windows.app tile-windows.applescript
```
Drag "Tile Windows.app" to your Dock. Clicking it tiles the two most-recent windows.

## How it works

- **Focus tracking**: Hammerspoon records every window focus event in a ring (up to 10 recent windows).
- **Tiling**: When triggered (hotkey or click), it grabs the two most-recently-focused *visible* windows and splits the main screen into two halves with a 6px gap between them.
- **Main screen**: Windows are always placed on the screen where the most-recent window currently lives (defaults to the main display).

## Alternative: no .app needed
If you just want the keyboard shortcut `Cmd+Ctrl+T`, skip step 4 — the Hammerspoon config already binds it.
