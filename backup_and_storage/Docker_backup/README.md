# Docker_backup

## Overview
Docker backup automation scripts for backing up Docker data to mounted storage, repairing existing installs, and refreshing cron jobs.

## Contents
- `correct_docker-backup.sh`
- `docker-backup.sh`
- `setup_docker-backup.sh`
- `update_docker-backup.sh`

## Usage
Run the install, correction, or update scripts as root on the target system after reviewing the configured paths.

## Notes
Backups are designed around a mounted NAS path and scheduled cron execution.
