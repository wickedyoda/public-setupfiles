# Public Setup Files

> Collection of scripts, configuration files, and documentation for the WickedYoda homelab.

---

## Quick Start

### Clone and Set Up

```bash
# Automatic setup (installs git if needed)
curl -s https://raw.githubusercontent.com/wickedyoda/public-setupfiles/refs/heads/main/update-from_repo.sh | sudo bash

# Or manual clone
git clone https://github.com/wickedyoda/public-setupfiles.git
cd public-setupfiles
chmod -R 755 .
```

### Update Scripts

```bash
# Pull latest changes
./update-from_repo.sh

# Or Python version
python3 update-from_repo.py
```

---

## 📚 Documentation

| Category | Description |
|----------|-------------|
| [Getting Started](.github/wiki/Getting-Started.md) | Clone, update, and basic usage |
| [Core Scripts](.github/wiki/Core-Scripts.md) | `update-from-repo`, system updates, log collection |
| [Docker Setup](.github/wiki/Docker-Setup.md) | Docker installation, compose examples, backups |
| [System Updates](.github/wiki/System-Updates.md) | Auto-updates, Kali updates, Debian upgrades |
| [Linux Setup](.github/wiki/Linux-Setup.md) | Debian/Ubuntu server config, fstab, permissions |
| [Monitoring](.github/wiki/Monitoring.md) | Uptime Kuma bot, SNMP, Telegraf, Observium |
| [Network](.github/wiki/Network.md) | WireGuard VPN, Pi-hole, domain lists |
| [NAS & Storage](.github/wiki/NAS-Storage.md) | SMB/CIFS mounts, backups, sync scripts |
| [Windows Batch Files](.github/wiki/Windows-Batch-Files.md) | Backup and automation scripts |
| [macOS Scripts](.github/wiki/macOS-Scripts.md) | Homebrew, system updates, window tiling |
| [Raspberry Pi](.github/wiki/Raspberry-Pi.md) | Pi setup, apps, mounts, media |
| [OpenWrt](.github/wiki/OpenWrt.md) | Router configuration |
| [Kali & Security](.github/wiki/Kali-Security.md) | Kali Linux setup, security tools |
| [Domain Lists](.github/wiki/Domain-Lists.md) | Blocklists, allowlists, filtering rules |
| [Troubleshooting](.github/wiki/Troubleshooting.md) | Common issues and solutions |

---

## 📁 Repository Structure

```
public-setupfiles/
├── .github/
│   ├── workflows/
│   │   ├── codeql.yml           # GitHub CodeQL security analysis
│   │   └── security-scans.yml   # ShellCheck, pip-audit, Docker Scout
│   ├── SECURITY_SCANS.md        # Security scanning documentation
│   └── secret_scanning.yml      # Secret scanning configuration
│
├── Docker_backup/               # Docker data backup scripts
│   ├── docker-backup.sh
│   ├── setup_docker-backup.sh
│   ├── correct_docker-backup.sh
│   └── update_docker-backup.sh
│
├── Email_domains_block_allow/   # Email server domain policies
│   ├── blocked_domains.md
│   └── email_domain_allow_block_list.md
│
├── Kali_tools_install/          # Kali Linux security tools
│   ├── Kalitoolsinstall.sh
│   └── setup_debian_kali_tools.sh
│
├── WG VPN setup/                # WireGuard client setup
│   └── install-wireguard-client.sh
│
├── batch_files/                 # Windows .bat automation scripts
│   ├── Various backup/sync scripts
│   └── Older Files/
│
├── cockpit/                     # Cockpit web admin installer
│   └── cockpit_install.sh
│
├── copy-move-files/             # Media file transfer scripts
│   ├── Brandons-Minecraft_backup.sh
│   ├── media_to_usb.sh
│   ├── nas public.sh
│   └── public_to_usb.sh
│
├── copy_palworld_local/         # Palworld server backup
│   └── copy_palworld_local.py
│
├── cron-job-setup-files/        # Cron job configuration
│   ├── setup_cron_job_updates.sh
│   ├── setup_cron_job_updates-nomount.sh
│   └── CronUpdates-readme.txt
│
├── debian-dist-upgrades/        # Debian version upgrade scripts
│   └── dist-upgrade.sh
│
├── debian-files/                # Debian utility scripts
│   ├── install-bashtop.sh
│   └── update_tailscale.sh
│
├── docker/                      # Docker and Docker Compose setups
│   ├── install_docker_debian.sh
│   ├── install_docker_ubuntu.sh
│   ├── jellyfin-docker-compose.yml
│   ├── portainer/
│   └── gluetun/
│
├── docker_stuff/                # Docker cleanup and utilities
│   ├── docker_cleanup_updates.sh
│   ├── install_docker_debian.sh
│   └── uptime_kurma_fix/
│
├── domains/                     # Domain block/allow lists
│   ├── bamboo_domains.txt
│   ├── bypass_sites.txt
│   ├── social_media.txt
│   ├── streaming_domains_whitelist.txt
│   └── known_porn_domains.txt
│
├── fstab-setup/                 # NAS mount configuration
│   ├── Fstab entries.txt
│   ├── setup-fstab.sh
│   └── setup-fstab-remake-mnt.sh
│
├── gather-logs/                 # System diagnostic script
│   └── gather_logs.sh
│
├── git_clone_setup/             # Git repository helpers
│   ├── Git_clone_local_checkout.md
│   └── README.md
│
├── kali-purple/                # Kali Purple security platform
│   └── install_kali_purple.sh
│
├── mac-scripts/                # macOS automation
│   ├── updates.sh
│   ├── system_updates.sh
│   ├── brewscripts/
│   ├── disable_DS_store.sh
│   ├── DS_STore_destroy.sh
│   ├── rsync basic.sh
│   └── tile-windows/
│
├── observium/                  # Observium monitoring agent
│   ├── custom_install.sh
│   └── observium_agent/
│
├── openwrt_scripts/             # OpenWrt router utilities
│   ├── openwrt_full-upgrade.sh
│   ├── installing_ipref.sh
│   └── openwrt_snmp_defaults.txt
│
├── paperless-ngx/               # Document management system
│   └── paperless-ngx-install.sh
│
├── pihole/                      # Pi-hole DNS blocklists
│   ├── blocklist.txt
│   ├── whitelist.txt
│   └── combined_list.txt
│
├── raspberrypi/                 # Raspberry Pi scripts
│   ├── rasp_pi_install_apps.sh
│   ├── raspberry_pi_fstab.sh
│   ├── Media_to_ap-share.sh
│   └── public_to_usb.sh
│
├── redirecting-desktop_and_documents/  # Windows folder redirection
│   └── redirectfiles.sh
│
├── reset_perms/                 # Permission reset utilities
│   ├── reset_perms.sh
│   └── reset_perms 1.sh
│
├── server_config/              # Debian/Ubuntu server templates
│   ├── debian/
│   └── ubuntu/
│
├── snmp/                       # SNMP configuration scripts
│   ├── setup_snmp.sh
│   ├── setup_snmp_openwrt.sh
│   ├── setup_snmp_openwrt_v2.sh
│   ├── setup_snmp_openwrt_publicv2.sh
│   └── Setup_snmp_macos.sh
│
├── system_command_run/         # Distributed SSH command execution
│   ├── Run_command_on_machines.sh
│   ├── run_command_on_machines.py'
│   ├── run_command_on_machines_Keys.py'
│   └── machines.txt
│
├── telegraf-setup-scripts/     # Telegraf metrics agent
│   ├── install-client.sh
│   └── update-telegraf-w-keys.sh
│
├── ubuntu-based/               # Ubuntu application installer
│   └── ubuntu_install_apps.sh
│
├── unblocked_domains_for_VPN/   # VPN bypass domain list
│   └── unblocked_domains.txt
│
├── updates_scripts/            # System update automation
│   ├── updates.sh
│   ├── updates.py
│   ├── kali-updates.sh
│   ├── docker-run-netdata-install.sh
│   └── fix_apt_influx.sh
│
├── uptime-updates/             # Uptime Kuma container sync bot
│   ├── uptime-bot.py
│   ├── config.yml
│   ├── container-monitor-map.yaml
│   ├── requirements.txt
│   └── setup-update_uptime-bot.sh
│
├── LICENSE                     # MIT License
├── SECURITY.md                 # Security policy
├── collect_info.sh             # System information collector
├── setup_cron_clean.sh         # Set up automated updates
├── update-from_repo.py         # Python repo sync script
├── update-from_repo.sh         # Bash repo sync script
└── updates_clean.sh            # Hardened update script for cron
```

---

## 🛡️ Security

- All scripts are included **as-is** without warranty
- Review any script before running
- Some scripts require root/sudo privileges
- Never commit secrets or credentials
- See [SECURITY.md](SECURITY.md) for details

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-script`)
3. Commit your changes (`git commit -m 'Add amazing script'`)
4. Push to the branch (`git push origin feature/amazing-script`)
5. Open a Pull Request

---

## 📄 License

MIT License — see [LICENSE](LICENSE) file.

---

## 📞 Contact

For issues or questions, open an issue on [GitHub](https://github.com/wickedyoda/public-setupfiles/issues).