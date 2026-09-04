# Core Scripts

This wiki documents the main automation scripts in the repository root.

---

## `update-from_repo.sh`

Bash script to clone/update the public-setupfiles repository.

**Location:** Repository root

**Usage:**
```bash
sudo ./update-from_repo.sh
```

**What it does:**
1. Auto-installs Git if not present (Debian/Ubuntu/OpenWrt)
2. Clones `https://github.com/wickedyoda/public-setupfiles.git`
3. Sets executable permissions on all files
4. Supports re-running to update existing clones

**Options:** None (simple script)

---

## `update-from_repo.py`

Python version of the repository sync script.

**Location:** Repository root

**Usage:**
```bash
python3 update-from_repo.py
```

**Dependencies:** None (uses only stdlib)

**What it does:**
- Same functionality as the shell script
- Installs Python 3 via apt if missing
- Uses subprocess to run git commands

---

## `setup_cron_clean.sh`

Installs automatic system updates as a system cron job.

**Location:** Repository root

**Usage:**
```bash
sudo ./setup_cron_clean.sh
```

**What it does:**
1. Installs cron package
2. Copies `updates_clean.sh` to `/usr/local/sbin/`
3. Creates `/etc/cron.d/auto_updates`
4. Schedules updates every 6 hours

**Cron Schedule:**
| Task | Schedule | Command |
|------|----------|---------|
| System updates | `0 */6 * * *` | `/usr/local/sbin/updates_clean.sh` |
| Mount verification | `5 */1 * * *` | `mount -a` |

**Log file:** `/var/log/auto_updates.log`

**MAILTO:** Commented out by default. Uncomment and set your email if you want update notifications.

---

## `updates_clean.sh`

The actual update script called by cron.

**Location:** Repository root (also copy at `/usr/local/sbin/updates_clean.sh`)

**Run manually:**
```bash
sudo ./updates_clean.sh
```

**What it does:**
1. `apt update` — Refresh package lists
2. `apt full-upgrade -y` — Apply all updates
3. `apt autoremove -y` — Remove orphaned packages
4. `apt autopurge -y` — Purge config of removed packages (Debian 11+)
5. `apt clean -y` — Clear local cache

**Logging:** All output goes to stdout and `/var/log/auto_updates.log`

---

## `collect_info.sh`

System information collection script.

**Location:** Repository root

**Usage:**
```bash
./collect_info.sh
```

**Output:** Creates `info.txt` with system details including:
- OS distribution and version
- Hostname and kernel
- CPU, memory, storage
- GPU and PCI/USB devices
- Network interfaces and routes
- Display configuration

---

## `gather-logs/gather_logs.sh`

Collects system logs for troubleshooting.

**Location:** `gather-logs/`

**Usage:**
```bash
./gather-logs.sh
```

**Generates:** `/tmp/{date}-{hostname}.zip` containing:
- `/var/log/` — syslog, auth, kern, daemon, dmesg, dpkg, apt
- `journalctl` — current boot and all logs
- System info — hostname, uname, df, free, ip addr, systemctl failed

---

## Comparison: Shell vs Python Update Scripts

| Feature | `update-from_repo.sh` | `update-from_repo.py` |
|---------|----------------------|----------------------|
| Language | Bash | Python |
| Git install | apt/opkg | apt only |
| Path typo | N/A | `pubic-setupfiles` (bug) |
| Permissions | 755 recursive | 777 recursive |
| Error handling | Basic | Try/except |

**Note:** The Python script has a typo in the clone path (`pubic-setupfiles` instead of `public-setupfiles`). Prefer the shell script for now.