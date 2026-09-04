# reset_perms

## Overview

Scripts to reset file and directory permissions on mounted storage.

---

## Files

| File | Description |
|------|-------------|
| `reset_perms.sh` | Reset permissions on specified mounts |
| `reset_perms 1.sh` | Alternative version |

---

## Usage

```bash
sudo ./reset_perms/reset_perms.sh
```

---

## What It Does

1. Creates mount directories if missing
2. Mounts specified devices
3. Creates bind mounts for timeshift
4. Sets permissions (777) on all paths

---

## Paths Reset

| Path | Device |
|------|--------|
| `/mnt/public` | /dev/sdc1 |
| `/mnt/public-bk` | /dev/sde1 |
| `/mnt/public2` | /dev/sdd1 |
| `/mnt/public2-bk` | /dev/sdb1 |
| `/mnt/timeshift` | Bind from public2 |
| `/mnt/timeshift1` | Bind from public2-bk |

---

## Permissions

- Owner: `root:root`
- Permissions: `777` (world read/write/execute)

---

## Notes

- Check device IDs match your system
- Modify mount commands if devices differ
- Run after system update or hardware change