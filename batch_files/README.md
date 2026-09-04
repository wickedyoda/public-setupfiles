# batch_files

## Overview

This directory contains Windows batch files (.bat) for automation, backups, and file management tasks in the WickedYoda homelab.

## Contents

- `Backup Videos.bat` — Backup video collections
- `Copy myvideos from nas to usb.bat` — Transfer NAS media to USB
- `Docker-Minecraft_backup.bat` — Backup Minecraft server containers
- `Downloads Backup.bat` — Download folder synchronization
- `Education to education nas.bat` — Educational file backup
- `IT work .bat` — IT-related file operations
- `Map Drives.bat` — Network drive mapping
- `Murder VM Backup.bat` — Virtual machine backup
- `NAS to 4tb Local USB.bat` — Full NAS to USB transfer
- `Pictures backup.bat` — Photo library backup
- `Skrym Copy from Nas to Local.bat` — Game file transfers
- `Skrym Copy to nas.bat` — Upload game saves to NAS
- `Sync Private Folders.bat` — Private data synchronization
- `Traver-desk VM Backup.bat` — Desktop VM backup
- `coding and programming backup.bat` — Code repository backup
- `familymedicalbackup.bat` — Family medical records backup
- Plus additional scripts in `Older Files/` subdirectory

## Usage

- Review each script before running
- Some scripts require **Administrator** privileges (right-click → Run as administrator)
- Update paths and credentials before execution
- Test in a non-production environment first

## Directory Structure

```
batch_files/
├── Various .bat files
├── Older Files/
│   ├── Complete backup.ps1
│   ├── Map Drives 1.bat
│   ├── Mapped drives.ps1
│   └── README.md
└── README.md
```

## Safety Notes

- Always back up critical data before running scripts
- Scripts may delete or overwrite existing files
- Use at your own risk