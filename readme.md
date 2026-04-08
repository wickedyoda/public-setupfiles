# public-setupfiles

## Overview
This repository is a collection of setup scripts, maintenance utilities, backup helpers, and infrastructure notes for Linux, macOS, Windows, Docker, and home-lab style systems.

## Layout
- `backup_and_storage/` contains backup jobs, file-copy helpers, mount setup, and folder redirection scripts.
- `platform_setup/` contains operating-system and platform-specific setup scripts for Debian, Ubuntu, Kali, macOS, Raspberry Pi, OpenWrt, Cockpit, and Paperless-ngx.
- `monitoring_and_remote_admin/` contains monitoring, SNMP, Observium, Telegraf, Docker monitoring helpers, and multi-machine command runners.
- `network_and_policies/` contains domain allow/block lists and VPN-related allowlists.
- `repo_automation/` contains repository maintenance helpers, cron setup utilities, reset scripts, and general update automation.

## Root Files
- `LICENSE` and `SECURITY.md` contain repository policy and licensing information.
- `public-setupfiles.code-workspace` is the workspace file for local editing.

## Notes
- Content was reorganized into category folders to make navigation easier without deleting existing scripts.
- Each project folder now has its own `README.md` describing what it contains.
- Review every script before running it on a live system, especially anything that changes mounts, packages, services, cron jobs, or Docker.
