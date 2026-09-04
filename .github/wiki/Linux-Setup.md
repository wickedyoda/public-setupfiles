# Linux Setup

Debian and Ubuntu system configuration scripts.

---

## Debian Files

### `debian-files/`

| Script | Purpose |
|--------|---------|
| `install-bashtop.sh` | Install system monitoring tool |
| `update_tailscale.sh` | Update Tailscale with keyring |

#### Bashtop Installation

```bash
sudo ./debian-files/install-bashtop.sh
```

Installs from GitHub source (latest development version).

#### Tailscale Update

```bash
sudo ./debian-files/update_tailscale.sh
```

**Features:**
- Detects Debian/Ubuntu/Raspbian
- Normalizes codenames (bullseye, bookworm, etc.)
- Falls back to legacy `apt-key` for older releases
- Installs from official Tailscale repo

---

## Debian Distro Upgrades

### `debian-dist-upgrades/`

| File | Purpose |
|------|---------|
| `README.md` | This documentation |
| `dist-upgrade.sh` | Interactive upgrade script |

#### `dist-upgrade.sh`

```bash
sudo ./debian-dist-upgrades/dist-upgrade.sh
```

**Supported upgrades:**
- Debian 11 → 12 (stable)
- Debian 12 → 13 (testing)

**Options:**
```
1) apt upgrade (security + bug fixes)
2) apt full-upgrade (recommended)
3) Debian distro upgrade (major version)
4) Convert to Parrot Linux (security-focused)
```

**Safety features:**
- Backup of `/etc/apt/sources.list`
- Double confirmation for Parrot conversion
- Automatic dependency handling

---

## Server Configuration

### `server_config/`

#### `server_config/debian/`

| File | Purpose |
|------|---------|
| `debian-setup.sh` | Initial Debian server setup |

**Commands included:**
```bash
# Install basic tools
apt install -y wireshark nmap openvpn etherape remmina monitorix

# Install networking
apt install -y openssh-server smbclient cifs-utils

# Install utilities
apt install -y curl unattended-upgrades cron-apt git
```

#### `server_config/ubuntu/`

| File | Purpose |
|------|---------|
| `ubuntu-setup.sh` | Ubuntu server initial setup |
| `ubuntu-docker-install.sh` | Docker on Ubuntu |

---

## fstab Setup

### `fstab-setup/`

| File | Purpose |
|------|---------|
| `Fstab entries.txt` | NAS mount configuration examples |
| `setup-fstab.sh` | Generate and apply fstab entries |
| `setup-fstab-remake-mnt.sh` | Reset and remount |

#### NAS Mount Entries

```bash
# Public share
//nas/public  /media/naspublic  cifs  vers=2.0,username=admin,password=YOURPASS,file_mode=0777,dir_mode=0777,_netdev,auto 0 0

# Media share
//nas/DownloadedMedia  /media/nasmedia  cifs  vers=2.0,username=admin,password=YOURPASS,file_mode=0777,dir_mode=0777,_netdev,auto 0 0
```

#### Setup Script

```bash
sudo ./fstab-setup/setup-fstab.sh
```

**What it does:**
1. Backs up existing `/etc/fstab`
2. Creates mount points
3. Appends new entries
4. Runs `mount -a` to activate

---

## Reset Permissions

### `reset_perms/`

| File | Purpose |
|------|---------|
| `reset_perms.sh` | Reset permissions on mount points |
| `reset_perms 1.sh` | Alternative version |

#### Usage

```bash
sudo ./reset_perms/reset_perms.sh
```

**Resets:**
```bash
/mnt/public      /dev/sdc1
/mnt/public-bk   /dev/sde1
/mnt/public2     /dev/sdd1
/mnt/public2-bk  /dev/sdb1
/mnt/timeshift   bind mount from public2
/mnt/timeshift1  bind mount from public2-bk
```

**Sets:**
- Ownership: `root:root`
- Permissions: `777` (world read/write/execute)

---

## Gather Logs

### `gather-logs/`

**Script:** `gather_logs.sh`

```bash
./gather-logs/gather_logs.sh
```

**Collects:**
- `/var/log/syslog`, `/var/log/auth.log`, `/var/log/kern.log`
- `journalctl` output (current boot + all)
- System info: hostname, uname, df, free, ip addr
- Failed systemd units

**Output:** `/tmp/{date}-{hostname}.zip`