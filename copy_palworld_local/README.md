# copy_palworld_local

## Overview

Python script for backing up Palworld server data to local storage or NAS.

## Files

| File | Description |
|------|-------------|
| `copy_palworld_local.py` | Main backup script |

## Usage

```bash
python3 copy-palworld-local/copy_palworld_local.py
```

---

## Configuration

Edit `copy_palworld_local.py` to set:
- Source directory (Palworld server data)
- Destination directory (local/NAS)
- Backup retention period

---

## Features

- Checks if destination exists
- Creates timestamped backup folders
- Handles permission errors gracefully
- Logs operation results

---

## Requirements

- Python 3.x
- Permissions to read Palworld server data
- Write access to destination