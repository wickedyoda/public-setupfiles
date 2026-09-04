# server_config

## Overview

Server configuration templates and scripts for Debian/Ubuntu servers.

---

## Files

| Directory | Description |
|-----------|-------------|
| `debian/` | Debian server setup scripts |
| `ubuntu/` | Ubuntu server setup scripts |

---

## Debian Setup

### `debian/debian-setup.sh`

Initial Debian server configuration:

```bash
sudo ./server_config/debian/debian-setup.sh
```

**Configures:**
- sudo access for user 'traver'
- open-vm-tools for VMware
- Git and wget
- Cockpit web UI
- Python

---

## Ubuntu Setup

### `ubuntu/ubuntu-setup.sh`

Initial Ubuntu server configuration:

```bash
sudo ./server_config/ubuntu/ubuntu-setup.sh
```

**Configures:**
- sudo access
- UFW removal (if desired)
- open-vm-tools
- Git and wget
- Cockpit web UI
- Python

---

### `ubuntu/ubuntu-docker-install.sh`

Docker installation on Ubuntu:

```bash
sudo ./server_config/ubuntu/ubuntu-docker-install.sh
```

**Installs:**
- Docker CE + CLI + containerd
- Docker Compose plugin
- Adds user to docker group

---

## First-Time Setup

```bash
# 1. Run server setup
sudo ./server_config/ubuntu/ubuntu-setup.sh
# OR
sudo ./server_config/debian/debian-setup.sh

# 2. Install Docker (optional)
sudo ./server_config/ubuntu/ubuntu-docker-install.sh

# 3. Set up updates
sudo ./setup_cron_clean.sh  # Auto-updates every 6h
```

---

## Post-Installation

After running these scripts:
1. Log out and back in (for group changes)
2. Access Cockpit at `https://server-ip:9090`
3. Configure Docker if installed
4. Review auto-update settings in `/etc/cron.d/auto_updates`