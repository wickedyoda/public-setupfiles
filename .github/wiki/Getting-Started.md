# Getting Started

This guide helps you get started with the **public-setupfiles** repository.

## 📥 Cloning

### Quick Install (Recommended)

The fastest way to get started is using the provided update script:

```bash
sudo curl -s https://raw.githubusercontent.com/wickedyoda/public-setupfiles/refs/heads/main/update-from_repo.sh | sudo bash
```

This script:
- Automatically installs Git if missing
- Clones the repository to `./public-setupfiles`
- Sets proper permissions

### Manual Clone

```bash
git clone https://github.com/wickedyoda/public-setupfiles.git
cd public-setupfiles
chmod -R 755 .
```

### Python Version (Alternative)

```bash
curl -s https://raw.githubusercontent.com/wickedyoda/public-setupfiles/refs/heads/main/update-from_repo.py | python3
```

---

## 🔄 Keeping Updated

### Automated Updates

Set up the automated update cron job:

```bash
sudo ./setup_cron_clean.sh
```

This installs `updates_clean.sh` to run every 6 hours.

### Manual Update

```bash
# From the repo root
./update-from_repo.sh

# Or using Python
python3 update-from_repo.py
```

---

## 📁 Navigation

| Directory | Purpose | Key Scripts |
|-----------|---------|-------------|
| `docker/` | Docker installations | `install_docker_debian.sh` |
| `server_config/` | Server setup templates | `debian-setup.sh` |
| `uptime-updates/` | Monitoring automation | `uptime-bot.py` |
| `snmp/` | Network monitoring | `setup_snmp.sh` |
| `pihole/` | DNS blocking | `blocklist.txt` |
| `domains/` | Domain lists | `blocked_domains.md` |

---

## ⚠️ Safety Notes

- Always review scripts before running them
- Some scripts require `sudo` or root access
- Test in a non-production environment first
- Backup critical data before making changes

---

## 🔧 Tools Used

| Tool | Purpose |
|------|---------|
| **ShellCheck** | Shell script linting |
| **CodeQL** | Static code analysis |
| **pip-audit** | Dependency vulnerability scan |
| **Docker Scout** | Container image security |

See [Security Scanning](Security-Scanning.md) for details.