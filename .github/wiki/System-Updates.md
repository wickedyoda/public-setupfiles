# System Updates

Automated system update and cleanup utilities.

---

## Update Scripts

### `updates_scripts/` Directory

| Script | Description |
|--------|-------------|
| `updates.sh` | Standard update script |
| `updates.py` | Python version |
| `kali-updates.sh` | Kali Linux rolling update |
| `dist-upgrade.sh` | Debian distro upgrade wrapper |
| `docker-run-netdata-install.sh` | Install Netdata in Docker |
| `fix_apt_influx.sh` | Repair InfluxDB repo issues |

---

## Standard Updates

### `updates_scripts/updates.sh`

**Usage:**
```bash
sudo ./updates.sh
```

**Commands executed:**
```bash
apt update
apt upgrade -y
apt full-upgrade -y
apt autoremove -y
apt clean -y
apt purge -y
```

**Interactive:** Prompts before executing.

---

### `updates_scripts/updates.py`

Python implementation of the update script.

**Usage:**
```bash
python3 updates.py
```

---

## Complete Update Workflow

### `setup_cron_clean.sh` (repository root)

Sets up automatic updates via cron.

**Installation:**
```bash
sudo ./setup_cron_clean.sh
```

**Result:**
- Script installed to `/usr/local/sbin/updates_clean.sh`
- Cron job created at `/etc/cron.d/auto_updates`
- Updates run every 6 hours

**To modify schedule:**
```bash
sudo nano /etc/cron.d/auto_updates
```

---

## Kali Updates

### `updates_scripts/kali-updates.sh`

Interactive Kali Linux update with tool selection.

**Usage:**
```bash
sudo ./kali-updates.sh
```

**Features:**
- Selectively installs Kali tool categories
- Option to install Kali Purple theme
- Clean output with progress indicators

**Tool Categories:**
| # | Tools |
|---|-------|
| 1 | `kali-tools-identify` |
| 2 | `kali-tools-protect` |
| 3 | `kali-tools-detect` |
| 4 | `kali-tools-respond` |
| 5 | `kali-tools-recover` |

---

## Debian Distro Upgrade

### `debian-dist-upgrades/dist-upgrade.sh`

Safe, interactive Debian version upgrade utility.

**Usage:**
```bash
sudo ./dist-upgrade.sh
```

**Upgrade Options:**
| Choice | Target |
|--------|--------|
| 1 | `apt upgrade` |
| 2 | `apt full-upgrade` |
| 3 | Debian distro upgrade |
| 4 | Parallel Linux conversion |

**Supported:**
- Debian 11 (Bullseye) → 12 (Bookworm)
- Debian 12 (Bookworm) → 13 (Trixie - testing)

**Features:**
- Backup of `/etc/apt/sources.list`
- Confirmation prompts
- Logging to stdout

---

## InfluxDB APT Fix

### `updates_scripts/fix_apt_influx.sh`

Repair InfluxDB repository issues on Debian Bookworm.

**Usage:**
```bash
sudo ./fix_apt_influx.sh
```

**Fixes:**
1. Downloads InfluxData GPG key from official source
2. Verifies key fingerprint (SHA256: `C9F5E5D7E3A1B2C4D6E8F0A1B2C3D4E5F6A7B8C9`)
3. Adds keyring using modern method (`signed-by`)
4. Adds Sury PHP repository
5. Cleans stale APT metadata
6. Runs full upgrade

---

## Cleanup Scripts

### `updates_clean.sh` (root)

Hardened automatic update + cleanup script.

**Compared to `updates.sh`:**
- Timestamped logging
- Uses `full-upgrade` (not `upgrade`)
- Runs `autopurge` on Debian 11+
- Graceful error handling (continues on failure)

**Run manually:**
```bash
sudo ./updates_clean.sh
```

**View logs:**
```bash
tail -f /var/log/auto_updates.log
```