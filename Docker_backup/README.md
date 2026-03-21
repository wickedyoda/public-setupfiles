# Docker_backup

## Overview
This directory contains the Docker backup scripts for this repository.

## Files
- `docker-backup.sh` backs up Docker data to the NAS share.
- `setup_docker-backup.sh` installs the backup script and cron job on a new system.
- `correct_docker-backup.sh` repairs older installs and rewrites the cron job.

## Usage
- Review the scripts before running them.
- Run the install or correction scripts as `root`.
- Adjust paths if the target system uses different Docker or NAS mount locations.

## Notes
- Backups are written to `/mnt/naspublic/docker-backup/{hostname}/{month}/{date}/`.
- The backup job runs every 3 hours.
- Backups older than 14 days are removed automatically.
