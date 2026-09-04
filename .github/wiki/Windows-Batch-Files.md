# Windows Batch Files

Windows automation scripts for backups, file transfers, and system management.

---

## Backup Scripts

### `batch_files/ABC---Backup VM's.bat`

Backup virtual machines.

```batch
# Usage: Run as Administrator
# Creates backup of VM directories
```

---

### `batch_files/Backup Videos.bat`

Video file backup utility.

**Features:**
- Progress tracking
- Timestamped logs
- Destination: USB drive

---

### `batch_files/Traver-desk VM Backup.bat`

Desktop VM backup.

**Scheduled usage:** Run daily via Task Scheduler.

---

### `batch_files/Murder VM Backup.bat`

Game VM backup (likely Minecraft or similar).

---

### `batch_files/familymedicalbackup.bat`

Family medical records backup.

---

## File Transfer Scripts

### `batch_files/Docker-Minecraft_backup.bat`

Minecraft server backup via Docker.

```batch
# Stops container, backs up, restarts
docker stop minecraft
robocopy C:\Docker\Containers\Minecraft\Data E:\Backups\Minecraft
docker start minecraft
```

---

### `batch_files/Downloads Backup.bat`

Downloads folder backup.

**Destinations:**
- NAS share
- USB drive (rotation)

---

## Sync Scripts

### `batch_files/Sync Private Folders.bat`

Sync personal folders to NAS.

**Folders synced:**
- Documents
- Pictures
- Desktop

---

### `batch_files/Education to education nas.bat`

Educational materials backup.

---

## Drive Mapping

### `batch_files/Map Drives.bat`

Map network drives.

```batch
net use Z: \\nas\public /persistent:yes
net use Y: \\nas\media /persistent:yes
```

---

### `batch_files/NAS to 4tb Local USB.bat`

Full NAS to USB backup.

**Schedule:** Weekly full backup.

---

## Media Scripts

### `batch_files/IT work .bat`

Technical work folder sync.

### `batch_files/Pictures backup.bat`

Photo library backup.

### `batch_files/Skyrim Copy from Nas to Local.bat`

Game file download.

### `batch_files/Skyrim Copy to nas.bat`

Upload saved games to NAS.

---

## Command Reference

| Command | Purpose |
|---------|---------|
| `robocopy` | Robust file copy with progress |
| `net use` | Map network drives |
| `docker` | Container management |
| `schtasks` | Schedule tasks |

---

## Requirements

- Run as **Administrator** for full access
- NAS must be accessible at configured IP
- USB drives should be labeled consistently