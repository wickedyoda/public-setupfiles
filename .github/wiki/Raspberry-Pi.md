# Raspberry Pi

Raspberry Pi setup scripts for media, backups, and system configuration.

---

## Scripts

### Location: `raspberrypi/`

| File | Purpose |
|------|---------|
| `rasp_pi_install_apps.sh` | Install applications |
| `raspberry_pi_fstab.sh` | Configure mounts |
| `Media_to_ap-share.sh` | Sync to AP share |
| `public_to_usb.sh` | Transfer to USB |

---

## App Installation

### `rasp_pi_install_apps.sh`

Initial package installation for Raspberry Pi.

```bash
# Network tools
apt install wireshark nmap openvpn etherape remmina

# Storage
apt install cifs-utils exfat-fuse

# System utilities
apt install curl git python software-properties-common

# Optional: Media server
curl -fsSL https://pi.vpetkov.net -o ventz-media-pi
sh ventz-media-pi
```

---

## fstab Configuration

### `raspberry_pi_fstab.sh`

Configure network mounts on Raspberry Pi.

**Mounts configured:**
```
/media/naspublic      //nas/public
/media/nasdownloadedmedia   //nas/DownloadedMedia
/media/naspublic-share2 //nas/public-share2
```

**Usage:**
```bash
sudo ./raspberrypi/raspberry_pi_fstab.sh
```

---

## Media Sync

### `Media_to_ap-share.sh`

Sync media to Apple TV share.

```bash
sudo mount -a
rsync -r --progress --delete \
  /media/nasmedia/Movies/ \
  /media/traver/File_store/
```

---

### `public_to_usb.sh`

Transfer public files to USB drive.

```bash
sudo mount -a
rsync -r --progress --delete \
  /media/naspublic/ \
  /media/pi/4tb/public
```

---

## Pi-Specific Considerations

### Memory

- Swap may need configuration for large updates
- `dphys-swapconf` for swap file management

### Storage

- SD card wear: Use log2ram or tmpfs for `/var/log`
- Backup regularly

### Network

- Ensure stable WiFi or Ethernet connection
- Static IP recommended for NAS mounts

---

## Quick Start

```bash
# 1. Update system
sudo apt update && sudo apt upgrade -y

# 2. Install apps
sudo ./raspberrypi/rasp_pi_install_apps.sh

# 3. Configure mounts
sudo ./raspberrypi/raspberry_pi_fstab.sh
```