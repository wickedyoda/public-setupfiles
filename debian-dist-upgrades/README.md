# debian-dist-upgrades

## Overview

A safe, interactive Debian system upgrade utility with guardrails and logging.

---

## Contents

| File | Description |
|------|-------------|
| `dist-upgrade.sh` | Interactive upgrade script |

---

## Usage

```bash
sudo ./debian-dist-upgrades/dist-upgrade.sh
```

---

## Upgrade Options

| Choice | Description |
|--------|-------------|
| 1 | `apt upgrade` — Security and bug fixes only |
| 2 | `apt full-upgrade` — Recommended for regular updates |
| 3 | Debian distro upgrade (major version) |
| 4 | Convert to Parrot Linux (security-focused) |

---

## Upgrade Paths

### Minor Updates

```bash
# Security updates
apt update && apt upgrade -y
apt autoremove -y
```

### Major Version Upgrade

**Supported:**
- Debian 11 (Bullseye) → 12 (Bookworm)
- Debian 12 (Bookworm) → 13 (Trixie - testing)

**Process:**
1. Confirmation prompts
2. Backup of `/etc/apt/sources.list`
3. Update sources to new release
4. Run upgrades

---

## Debian 13 (Trixie) Notes

⚠️ **Testing Release Warning**

Before proceeding:
- Understand this is a testing release
- Have backups ready
- Test in non-production environment

---

## Parrot Linux Conversion

Option 4 allows converting Debian to Parrot Security/Privacy OS.

**Prerequisites:**
- Internet connection
- 2-4 hours time
- Disk space for additional packages

---

## Safety Features

- Interactive confirmation before each step
- Sources.list backup before distro upgrade
- Proper handling of config files
- Cleanup of temporary files

---

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Invalid input |
| 2 | OS not Debian-based |
| 3 | User cancelled |