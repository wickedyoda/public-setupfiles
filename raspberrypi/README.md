# raspberrypi

## Overview

Scripts for Raspberry Pi setup, applications, and storage configuration.

---

## Files

| Script | Description |
|--------|-------------|
| `rasp_pi_install_apps.sh` | Install common applications |
| `raspberry_pi_fstab.sh` | Configure network mounts |
| `Media_to_ap-share.sh` | Sync media to Apple TV share |
| `public_to_usb.sh` | Transfer public files to USB |

---

## Application Installation

### `rasp_pi_install_apps.sh`

```bash
sudo ./raspberrypi/rasp_pi_install_apps.sh
```

**Installs:**
- Network tools: wireshark, nmap, openvpn, etherape, remmina
- Storage tools: cifs-utils, exfat-fuse
- Utilities: curl, git, python, unattended-upgrades, cron-apt
- Media server: ventz-media-pi (optional)

---

## fstab Configuration

### `raspberry_pi_fstab.sh`

```bash
sudo ./raspberrypi/raspberry_pi_fstab.sh
```

**Configures:**
```
/media/naspublic
/media/nasdownloadedmedia
/media/naspublic-share2
```

---

## Media Sync

### `Media_to_ap-share.sh`

```bash
sudo ./raspberrypi/Media_to_ap-share.sh
```

Syncs movies to Apple TV media share.

---

### `public_to_usb.sh`

```bash
sudo ./raspberrypi/public_to_usb.sh
```

Transfers NAS public share to USB drive.

---

## Raspberry Pi Tips

### SD Card Wear

Consider using tmpfs for `/var/log`:

```bash
# Add to /etc/fstab
tmpfs /var/log tmpfs defaults,noatime,nosuid,size=100M 0 0
```

### Network

- Use static IP for stable NAS mounts
- Consider WiFi power management: `sudo iw dev wlan0 set power_save off`

### Storage

- External USB drives should be labeled consistently
- Use UUIDs in fstab for reliability: `fstab` with UUID mounts more reliable than device paths

---

## Quick Start

```bash
# 1. Update system
sudo apt update && sudo apt upgrade -y

# 2. Install applications
sudo ./raspberrypi/rasp_pi_install_apps.sh

# 3. Configure mounts
sudo ./raspberrypi/raspberry_pi_fstab.sh

# 4. Reboot
sudo reboot
```