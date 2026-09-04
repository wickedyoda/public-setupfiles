# ubuntu-based

## Overview

Scripts for Ubuntu-based system setup and application installation.

---

## Files

| Script | Description |
|--------|-------------|
| `ubuntu_install_apps.sh` | Install common applications on Ubuntu |

---

## Usage

```bash
sudo ./ubuntu-based/ubuntu_install_apps.sh
```

---

## What It Installs

The script installs a curated set of applications commonly needed on Ubuntu systems:

### Development Tools
- git, curl, wget

### System Utilities
- htop (system monitoring)
- tmux (terminal multiplexer)

### Networking
- openssh-server
- nmap (network scanner)

### Media
- VLC media player
- ffmpeg (video/audio tools)

### Productivity
- KeepassXC (password manager)
- LibreOffice (office suite)

---

## Requirements

- Ubuntu 20.04+ recommended
- Root/sudo access
- Internet connection

---

## Post-Installation

After running the script:
1. Log out and back in for group changes
2. Review installed applications
3. Configure any tools that need customization

---

## Related

- `debian-files/` — For Debian systems
- `updates_scripts/` — For system updates