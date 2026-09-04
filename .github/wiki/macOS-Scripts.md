# macOS Scripts

macOS automation and system management utilities.

---

## System Updates

### `mac-scripts/updates.sh`

Update Homebrew and system packages.

```bash
# Update Homebrew
brew update && brew upgrade

# Update Casks
brew upgrade --cask

# Clean up
brew cleanup
brew autoremove
```

**macOS Software Update:**
```bash
softwareupdate -l  # List available
softwareupdate -i -a  # Install all
```

---

### `mac-scripts/system_updates.sh`

Interactive system update script.

**Features:**
- macOS Software Update
- Homebrew update
- NPM update
- Pip packages update

---

### `mac-scripts/brewscripts/update-brew-packages.sh`

Remove deprecated Homebrew casks.

**Usage:**
```bash
brew install --cask gstreamer  # Install replacement
./mac-scripts/brewscripts/update-brew-packages.sh
```

---

## .DS_Store Management

### `mac-scripts/disable_DS_store.sh`

Disable .DS_Store creation on network volumes.

```bash
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool TRUE
```

### `mac-scripts/DS_STore_destroy.sh`

Comprehensive .DS_Store cleanup.

**Features:**
- Disable on USB/Network volumes
- Add to global git ignore
- Delete existing files
- Restart Finder

---

## Window Management

### `mac-scripts/tile-windows/`

One-click window tiling using Hammerspoon.

#### Files

| File | Purpose |
|------|---------|
| `hammerspoon-init.lua` | Tiling logic |
| `tile-windows.applescript` | Clickable app |

#### Setup

```bash
# 1. Install Hammerspoon
brew install --cask hammerspoon

# 2. Copy config
cp mac-scripts/tile-windows/hammerspoon-init.lua ~/.hammerspoon/init.lua

# 3. Reload Hammerspoon
hs -c "hs.reload()"
```

#### Usage

- **Keyboard:** `Cmd+Ctrl+T`
- **Dock:** Drag "Tile Windows.app" to Dock
- **Menu:** Hammerspoon menubar → Reload All

---

## Homebrew Scripts

### `mac-scripts/brewscripts/`

| Script | Purpose |
|--------|---------|
| `update-brew-packages.sh` | Update Homebrew + casks |
| `README.md` | Documentation |

---

## Tools Installed

The macOS setup installs these tools:

| Category | Tools |
|----------|-------|
| Development | git, python, node |
| Networking | wireshark, nmap, openvpn |
| Multimedia | vlc, ffmpeg |
| Utilities | bashtop, htop |
| Productivity | keepassxc, libreoffice |

---

## Usage

```bash
# Run a script
./mac-scripts/updates.sh

# Or with Zsh
zsh mac-scripts/system_updates.sh
```

> **Note:** Some scripts require Hammerspoon accessibility permissions.

### Grant Permissions

System Settings → Privacy & Security → Accessibility → Add Hammerspoon.app