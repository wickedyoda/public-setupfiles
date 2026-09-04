# kach-purple

## Overview

Kali Purple installation script for setting up the Kali Linux Purple security platform.

---

## Files

| File | Description |
|------|-------------|
| `install_kali_purple.sh` | Main installation script |

---

## Usage

```bash
sudo ./kali-purple/install_kali_purple.sh
```

---

## What It Installs

1. **Kali Purple Tools**
   - `kali-tools-identify`
   - `kali-tools-protect`
   - `kali-tools-detect`
   - `kali-tools-respond`
   - `kali-tools-recover`

2. **Purple Experience**
   - `kali-themes-purple` — Purple theme
   - `kali-menu` — Kali menu system
   - `kali-wallpapers-legacy` — Legacy wallpapers

3. **System Updates**
   - Updates Kali sources.list
   - Installs all available packages
   - Cleans up

---

## Prerequisites

- Kali Linux or Debian-based system
- Root/sudo access
- Internet connection

---

## Interactive Prompts

The script will prompt for:
- Which Kali Purple tool categories to install (1-5 or 'all')
- Kali Purple experience options (1-4)

---

## Post-Installation

After installation completes:
- Log out and back in to see theme changes
- Kali Purple tools available in applications menu
- Verify installation with `kali-menu` command