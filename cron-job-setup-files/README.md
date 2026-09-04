# cron-job-setup-files

## Overview

This directory contains scripts and documentation for configuring automatic cron jobs on Linux systems.

## Files

| File | Description |
|------|-------------|
| `setup_cron_job_updates.sh` | Install auto-updates via /etc/cron.d |
| `setup_cron_job_updates-nomount.sh` | Auto-updates without mount requirement |
| `CronUpdates-readme.txt` | Usage documentation |

## Usage

### Install System Updates

```bash
sudo ./setup_cron_job_updates.sh
```

### Install Without Mount Dependencies

```bash
sudo ./setup_cron_job_updates-nomount.sh
```

This version:
- Skips `mount -a` before updates
- Safer for systems without guaranteed mounts

---

## Cron Schedule

Default cron job (`/etc/cron.d/auto_updates`):

| Time | Command |
|------|---------|
| `0 */6 * * *` | `apt-get update && apt-get -y full-upgrade && apt-get autoremove -y` |
| `0 */1 * * *` | `mount -a` (if enabled) |

---

## Log Location

```
/var/log/auto_updates.log
```

---

## Environment Variables

For non-root execution, set:

```bash
MAILTO="alerts@tyates.one"
```

---

## References

- [Cron job setup](CronUpdates-readme.txt) for detailed documentation
- `setup_cron_clean.sh` in repository root for updated/cleaner version