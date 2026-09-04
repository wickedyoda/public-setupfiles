# paperless-ngx

## Overview

Script for installing Paperless-ngx document management system.

---

## Files

| File | Description |
|------|-------------|
| `paperless-ngx-install.sh` | Installation script |

---

## Usage

```bash
sudo ./paperless-ngx/paperless-ngx-install.sh
```

---

## What It Does

The script automates the installation of:
- Docker
- Docker Compose
- Paperless-ngx container
- Required dependencies

---

## Post-Installation

After running the script:
1. Access Paperless-ngx web interface
2. Create admin account
3. Configure document sources
4. Start ingesting documents

---

## Requirements

- Debian/Ubuntu system
- Root/sudo access
- Minimum 2GB RAM recommended
- Storage for documents

---

## Configuration Notes

The script may set up:
- Docker volume for data persistence
- Port mapping (usually 8000)
- Environment variables for configuration