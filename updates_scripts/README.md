# updates_scripts

## Overview

Automated system update scripts for various platforms and use cases.

---

## Scripts

| File | Description | Platform |
|------|-------------|----------|
| `updates.sh` | Standard update script | Linux |
| `updates.py` | Python version of updates.sh | Linux |
| `kali-updates.sh` | Kali Linux rolling update with tool selection | Kali/Debian |
| `docker-run-netdata-install.sh` | Install Netdata in Docker | Docker host |
| `fix_apt_influx.sh` | Repair InfluxDB APT repository | Debian |
| `dist-upgrade.sh` | Debian distro upgrade wrapper | Debian |

---

## Standard Updates

### `updates.sh`

```bash
sudo ./updates.sh
```

**Commands:**
```bash
apt update
apt upgrade -y
apt full-upgrade -y
apt autoremove -y
apt clean -y
apt purge -y
```

---

## Kali Updates

### `kali-updates.sh`

```bash
sudo ./kali-updates.sh
```

**Features:**
- Updates Kali rolling release
- Interactive tool selection
- Optional Kali Purple installation

---

## Docker Netdata

### `docker-run-netdata-install.sh`

```bash
sudo ./docker-stuff/docker_run-netdata-install.sh
```

Creates a Netdata container for host metrics monitoring.

---

## InfluxDB Fix

### `fix_apt_influx.sh`

```bash
sudo ./updates_scripts/fix_apt_influx.sh
```

**Fixes:**
- InfluxDB repo key verification
- Sury PHP repo setup
- Stale APT metadata cleanup

---

## Dist Upgrade

### `dist-upgrade.sh`

Interactive tool for moving to newer Debian releases.

```bash
sudo ./debian-dist-upgrades/dist-upgrade.sh
```

See `debian-dist-upgrades/` for details.

---

## Related Scripts

- `setup_cron_clean.sh` (repo root) — Schedules these scripts
- `updates_clean.sh` (repo root) — Hardened cron version