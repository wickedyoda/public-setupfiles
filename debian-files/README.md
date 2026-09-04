# debian-files

## Overview

Utility scripts for Debian-based Linux systems.

---

## Files

| Script | Purpose |
|--------|---------|
| `install-bashtop.sh` | Install system monitoring tool |
| `update_tailscale.sh` | Update Tailscale with keyring |

---

## Installing Bashtop

```bash
sudo ./debian-files/install-bashtop.sh
```

**What it does:**
1. Clones bashtop from GitHub
2. Compiles and installs
3. Note: Uses development version

---

## Updating Tailscale

```bash
sudo ./debian-files/update_tailscale.sh
```

**Features:**
- Detects Debian/Ubuntu/Raspbian
- Downloads official repo
- Uses keyring-based installation (modern method)
- Falls back to legacy `apt-key` for older releases

**Supported distros:**
- Debian 10 (Buster), 11, 12
- Ubuntu 18.04, 20.04, 22.04, 24.04
- Raspbian

---

## Usage Notes

- Run scripts as root or with sudo
- Scripts may modify `/etc/apt/sources.list.d/`
- First-time run requires internet access for package downloads