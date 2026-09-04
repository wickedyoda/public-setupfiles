# NAS & Storage

Network Attached Storage setup, SMB/CIFS mounting, and backup scripts.

---

## SMB/NAS Mount Setup

### `fstab-setup/`

Configure NAS shares via `/etc/fstab`.

| File | Purpose |
|------|---------|
| `Fstab entries.txt` | Pre-built mount examples |
| `setup-fstab.sh` | Apply fstab changes |
| `setup-fstab-remake-mnt.sh` | Re-create mount points |

### Mount Entry Format

```
//server/share  /mount/point  cifs  options  0 0
```

### Common Entries

```bash
# Public share (read/write)
//nas/public  /mnt/naspublic  cifs  vers=2.0,username=admin,password=YOURPASS,file_mode=0777,dir_mode=0777,_netdev,auto 0 0

# Download media
//nas/DownloadedMedia  /mnt/nasmedia  cifs  vers=2.0,username=admin,password=YOURPASS,file_mode=0777,dir_mode=0777,_netdev,auto 0 0

# Public2 share
//nas/public-share2  /mnt/naspublic-share2  cifs  vers=2.0,username=admin,password=YOURPASS,file_mode=0777,dir_mode=0777,_netdev,auto 0 0
```

### Setup Script

```bash
sudo ./fstab-setup/setup-fstab.sh
```

---

## NAS Share Management

### `copy-move-files/`

Scripts for copying and moving media between NAS and local storage.

| Script | Purpose |
|--------|---------|
| `media_to_usb.sh` | Copy NAS media to USB drive |
| `public_to_usb.sh` | Transfer public share to USB |
| `nas public.sh` | Sync from NAS to local |
| `Brandons-Minecraft_backup.sh` | Minecraft world backup |

### Example Usage

```bash
# Copy media to USB
sudo ./copy-move-files/media_to_usb.sh

# Sync public share
sudo ./copy-move-files/nas\ public.sh
```

---

## Docker Backup

### Location: `Docker_backup/`

Complete Docker data backup solution.

| File | Purpose |
|------|---------|
| `docker-backup.sh` | Main backup script |
| `setup_docker-backup.sh` | Install + schedule |
| `correct_docker-backup.sh` | Fix older installs |
| `update_docker-backup.sh` | Upgrade existing |

### Backup Contents

```
/mnt/naspublic/docker-backup/{hostname}/{month}/{date}/
├── /root/docker
├── /opt/docker
├── /var/lib/docker/volumes
└── /home/traver/docker
```

### Installation

```bash
sudo ./Docker_backup/setup_docker-backup.sh
```

**Schedule:** Every 3 hours via cron

**Retention:** 14 days

---

## Raspberry Pi Storage

### Location: `raspberrypi/`

SD card and USB storage management.

| Script | Purpose |
|--------|---------|
| `raspberry_pi_fstab.sh` | Configure fstab for Pi |
| `rasp_pi_install_apps.sh` | Install apps on Pi |
| `Media_to_ap-share.sh` | Sync to AP share |
| `public_to_usb.sh` | Transfer to USB |

---

## Permission Management

### `reset_perms/`

Reset file permissions on mount points.

```bash
sudo ./reset_perms/reset_perms.sh
```

**Resets permissions to:**
- Owner: `root:root`
- Permissions: `777` (full read/write/execute)

**Applies to:**
```
/mnt/public
/mnt/public-bk
/mnt/public2
/mnt/public2-bk
/mnt/timeshift
/mnt/timeshift1
```

---

## System Information

### `collect_info.sh` (repo root)

Generate system information report.

```bash
./collect_info.sh
```

**Output:** `info.txt`

**Contains:**
- OS and kernel version
- CPU and memory
- Storage layout
- Network interfaces
- GPU information
- Display configuration