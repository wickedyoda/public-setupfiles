# Public Setup Files

This repository contains a collection of scripts and configuration snippets I use across various systems. Most scripts target Debian/Ubuntu Linux, but you'll also find utilities for macOS, Raspberry Pi, OpenWrt, and Docker environments.  The goal is to speed up system deployment and automate routine maintenance tasks.

## Directory overview

- **Email_domains_block_allow/** – Lists of domains to allow or block for email filtering.
- **Kali_tools_install/** – Scripts to install popular Kali Linux security tools on Debian-based systems.
- **batch_files/** – Windows batch files for backups and other automation.
- **blocked_domains/** – Domain blocklists used by some of the setup scripts.
- **cockpit/** – Installation helper for the Cockpit web administration interface.
- **copy-move-files/** – Shell scripts to copy or move media files between locations.
- **copy_palworld_local/** – Python helper for backing up Palworld server data.
- **cron-job-setup-files/** – Tools for configuring recurring cron jobs.
- **debian-files/** – Miscellaneous Debian utilities (e.g., installing bashtop).
- **docker/** – Docker and Docker Compose setups including Greenbone, Jellyfin and Portainer.
- **fstab-setup/** – Scripts to build and apply `/etc/fstab` mount entries.
- **git_clone_setup/** – Notes and helpers for cloning repositories.
- **mac-scripts/** – Assorted macOS helper scripts.
- **observium/** – Installer for the Observium monitoring agent.
- **openwrt_scripts/** – Utilities for managing OpenWrt routers.
- **paperless-ngx/** – Script to install the Paperless‑ngx document server.
- **raspberrypi/** – Backup and application install scripts for Raspberry Pi systems.
- **reset_perms/** – Simple scripts to reset file and directory permissions.
- **server_config/** – Example configuration files for Debian and Ubuntu servers.
- **snmp/** – SNMP configuration scripts for Linux and OpenWrt.
- **system_command_run/** – Run a command across multiple machines via SSH.
- **telegraf-setup-scripts/** – Install script for the Telegraf metrics agent.
- **ubuntu-based/** – Application install script for Ubuntu-based systems.
- **unblocked_domains_for_VPN/** – Domain list allowed through a VPN connection.
- **updates_scripts/** – Scripts to update or upgrade packages on a system.

Root-level helper scripts include **update-from_repo.py** and **update-from_repo.sh** for pulling the latest version of this repository onto a server.

## Cloning this repository

Clone the repository and switch to the main branch:

```bash
git clone https://github.com/wickedyoda/public-setupfiles.git
cd public-setupfiles
```

Refer to individual directories for more detailed instructions.

