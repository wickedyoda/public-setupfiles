# Docker Backup

Scripts for backing up Docker data to NAS storage.

## Overview

This directory contains scripts for creating, restoring, and managing Docker data backups.

## Files

| Script | Description |
|--------|-------------|
| `docker-backup.sh` | Main backup script |
| `setup_docker-backup.sh` | Install backup script and cron job |
| `correct_docker-backup.sh` | Fix older installations |
| `update_docker-backup.sh` | Update existing backup scripts |
| `update_docker-backup.sh` | Update existing backup scripts |

## Usage

### First-time Setup

```bash
sudo ./setup_docker-backup.sh
```

This:
- Installs the backup script to `/usr/local/sbin/`
- Creates a cron job running every 3 hours
- Sets up logging to `/var/log/docker-backup.log`

### Manual Backup

```bash
sudo ./docker-backup.sh
```

### Restore from Backup

```bash
# Find latest backup
ls -lt /mnt/naspublic/docker-backup/$(hostname)/ | head

# Extract and restore
cd /
tar -xzf /path/to/backup.tar.gz
```

## Backup Contents

```
/mnt/naspublic/docker-backup/{hostname}/{month}/{date}/
├── /root/docker
├── /opt/docker
├── /var/lib/docker/volumes
└── /home/traver/docker
```

## Schedule

- **Frequency:** Every 3 hours
- **Cron:** `0 */3 * * *`
- **Retention:** 14 days (automated cleanup)

## Configuration

Edit `docker-backup.sh` to modify:
- `BACKUP_DEST` — Destination directory
- `RETENTION_DAYS` — How long to keep backups
- `DOCKER_PATHS` — Which paths to back up

## Notes

- Requires write access to NAS mount
- Large backups may take significant time
- Test restore procedure periodically