# Public Setup Files — Repository Wiki

Welcome to the **public-setupfiles** wiki! This repository contains a collection of scripts and configuration snippets used across various systems in the WickedYoda homelab.

---

## 📚 Wiki Index

| Category | Description |
|---------|-------------|
| [Getting Started](Getting-Started.md) | Quick start guide for cloning and using the repository |
| [Core Scripts](Core-Scripts.md) | Overview of `update-from-repo` and `setup_cron_clean.sh` |
| [Docker Setup](Docker-Setup.md) | Docker installation and backup utilities |
| [System Updates](System-Updates.md) | Automated update and cleanup workflows |
| [Linux Setup](Linux-Setup.md) | Debian and Ubuntu system configuration scripts |
| [Monitoring](Monitoring.md) | Uptime Kuma bot, SNMP, Telegraf, Observium |
| [Network](Network.md) | WireGuard VPN, Pi-hole, domains blocklists |
| [NAS & Storage](NAS-Storage.md) | fstab setup, backup scripts |
| [Windows Batch Files](Windows-Batch-Files.md) | Windows automation scripts |
| [macOS Scripts](macOS-Scripts.md) | Homebrew and system update utilities |
| [Raspberry Pi](Raspberry-Pi.md) | Raspberry Pi specific setup scripts |
| [OpenWrt](OpenWrt.md) | Router configuration utilities |
| [Kali & Security](Kali-Security.md) | Kali Linux and security tool installation |
| [Domain Lists](Domain-Lists.md) | Email, VPN, and content domain lists |
| [Troubleshooting](Troubleshooting.md) | Common issues and solutions |

---

## 🚀 Cloning the Repository

```bash
# Clone and set up in one command
sudo curl -s https://raw.githubusercontent.com/wickedyoda/public-setupfiles/refs/heads/main/update-from_repo.sh | sudo bash
```

---

## 📁 Repository Structure

```
public-setupfiles/
├── .github/                    # GitHub workflows and security config
│   ├── workflows/
│   └── SECURITY_SCANS.md
├── Docker_backup/               # Docker data backup scripts
├── Email_domains_block_allow/   # Email filtering domain lists
├── Kali_tools_install/          # Kali Linux security tools
├── WG VPN setup/                # WireGuard client setup
├── batch_files/                 # Windows batch automation
├── cockpit/                     # Cockpit web admin installer
├── copy-move-files/             # Media file transfer scripts
├── copy_palworld_local/         # Palworld server backup
├── cron-job-setup-files/        # Cron job configuration
├── debian-dist-upgrades/        # Debian version upgrade scripts
├── debian-files/                # Debian utility scripts
├── docker/                      # Docker compose setups
├── docker_stuff/                # Docker cleanup scripts
├── domains/                     # Domain block/allow lists
├── fstab-setup/                 # NFS/CIFS mount configuration
├── gather-logs/                 # System diagnostic script
├── git_clone_setup/             # Git repository helpers
├── kali-purple/                 # Kali Purple installation
├── mac-scripts/                 # macOS automation
├── observium/                   # Observium monitoring agent
├── openwrt_scripts/             # OpenWrt router utilities
├── paperless-ngx/               # Document management setup
├── pihole/                      # Pi-hole blocklists
├── raspberrypi/                 # Raspberry Pi setup scripts
├── redirecting-desktop_and_documents/  # Windows folder redirection
├── reset_perms/                 # Permission reset utilities
├── server_config/               # Debian/Ubuntu server templates
├── snmp/                        # SNMP configuration scripts
├── system_command_run/          # Distributed command execution
├── telegraf-setup-scripts/      # Telegraf metrics agent
├── ubuntu-based/                # Ubuntu application installer
├── unblocked_domains_for_VPN/   # VPN domain whitelist
├── updates_scripts/             # System update automation
└── uptime-updates/              # Uptime Kuma container sync bot
```

---

## 🛡️ Security

- This repository undergoes automated security scanning on every pull request.
- Review [SECURITY.md](SECURITY.md) for details on the scanning tools used.
- **Never commit secrets, credentials, or private keys.**

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Submit a pull request

All PRs are automatically scanned for security issues.

---

## 📞 Contact

For issues or questions, open an issue on GitHub or contact the maintainer through the WickedYoda homelab community.