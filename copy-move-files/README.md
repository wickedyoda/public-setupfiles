# copy-move-files

## Overview

Shell scripts for copying, moving, and synchronizing media files between local storage, NAS, and external drives.

## Files

| Script | Purpose |
|--------|---------|
| `Brandons-Minecraft_backup.sh` | Minecraft server world backup |
| `media_to_usb.sh` | Copy NAS media to USB |
| `nas public.sh` | Sync NAS public to local |
| `public_to_usb.sh` | Transfer public share to USB |

## Usage

### Copy Media to USB

```bash
sudo ./copy-move-files/media_to_usb.sh
```

### Sync NAS to Local

```bash
sudo ./copy-move-files/nas\ public.sh
```

### Public Share to USB

```bash
sudo ./copy-move-files/public_to_usb.sh
```

### Minecraft Backup

```bash
# Stops container and backs up world data
./copy-move-files/Brandons-Minecraft_backup.sh
```

---

## Configuration

Edit scripts to modify:
- Source paths (NAS mount points)
- Destination paths
- Rsync options

---

## Error Handling

Use `--dry-run` option with rsync to test:

```bash
rsync -avh --dry-run --progress /source/ /dest/
```

---

## Notes

- Run as root when mounting/dismounting
- Ensure NAS is mounted before running
- Check USB drive space before large transfers