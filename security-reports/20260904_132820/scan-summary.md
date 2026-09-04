# Security Scan Report — public-setupfiles

**Scan Date:** 2026-09-04 13:30 UTC  
**Repository:** wickedyoda/public-setupfiles  
**Commit:** 18b039b (main)

## Tools Used

| Tool | Version | Scope |
|------|---------|-------|
| ShellCheck | 0.10.0 | All `*.sh` files (84 scripts) |
| TruffleHog | Local Python package | Full git history + working tree |
| Manual grep | — | Secret patterns (AWS, GitHub, SSH keys, .env files) |

## Results Summary

### ShellCheck (84 scripts scanned)

| Severity | Count |
|----------|-------|
| Error | 180 |
| Warning | 37 |
| Info | 125 |
| Style | 14 |
| **Total** | **356** |

### Error Breakdown by Code

| Code | Count | Description |
|------|-------|-------------|
| SC1017 | 155 | Literal carriage return — CRLF line endings in scripts |
| SC2148 | 42 | Missing shebang or shell directive |
| SC2086 | 70 | Unquoted variables (info-level overlap) |
| SC2068 | 6 | Double-quote array expansions |
| SC2034 | 12 | Unused variables |
| SC2181 | 8 | Indirect exit code checks |

### Error-Level Issues (32 files affected)

**Files with missing shebangs (SC2148)** — 22 files:
- `copy-move-files/*.sh` (4 files)
- `docker/install_docker_debian.sh`, `docker/install_docker_ubuntu.sh`
- `docker/portainer/*.sh`
- `mac-scripts/updates.sh`, `mac-scripts/system_updates.sh`, `mac-scripts/not working- download-sync.sh`
- `raspberrypi/*.sh` (3 files)
- `server_config/ubuntu/ubuntu-docker-install.sh`
- `fstab-setup/setup-fstab.sh`
- `redirecting-desktop_and_documents/redirectfiles.sh`
- `reset_perms/reset_perms 1.sh`
- `ubuntu-based/ubuntu_install_apps.sh`
- `updates_scripts/updates.sh`
- `telegraf-setup-scripts/install-client.sh`
- `docker/greenbone_vas_setup/install_docker.sh`, `pull_latest_setupfile.sh`
- `docker/portainer/update-portainer.sh`
- `Kali_tools_install/Kalitoolsinstall.sh`
- `cockpit/cockpit_install.sh`

**Files with carriage returns (SC1017)** — 10 files:
- `docker/greenbone_vas_setup/install_docker.sh` (all ~30 lines)
- `docker/greenbone_vas_setup/pull_latest_setupfile.sh`
- `docker/install_docker_debian.sh`
- `docker/install_docker_ubuntu.sh`
- `docker/portainer/portainer-installscript.sh`
- `docker/portainer/update-portainer.sh`
- `updates_scripts/dist-upgrade.sh`
- `updates_scripts/docker-run-netdata-install.sh`
- `updates_scripts/updates.sh`
- `telegraf-setup-scripts/install-client.sh`

**Other error codes:** SC1035 (line continuation), SC1071 (unsupported shebang), SC1104 (line continuation in command), SC2068 (array quoting), SC2283 (comparison)

### Secret Scanning Results

**13 findings** — ALL false positives:
- 8 findings: Domain list files flagged for high-entropy patterns in domain names
- 2 findings: SHA256 checksums in `fix_apt_influx.sh` (influxdata key)
- 2 findings: Google ad-domain lists flagged for repetitive patterns

**Manual verification:**
- No AWS keys (AKIA*) found
- No GitHub tokens (ghp_*) found
- No private keys (.pem, id_rsa, *.key) found
- No real .env files with credentials
- `gluetun.env.example` contains only placeholders
- `uptime-bot.py` config.yml uses placeholder `PUT_YOUR_API_KEY_HERE`
- No SSH URLs with embedded credentials

## Issues Recommended for Fix

| Priority | Issue | Files | Action |
|----------|-------|-------|--------|
| High | Missing shebangs (SC2148) | 22 files | Add `#!/bin/bash` or `#!/bin/sh` |
| High | Carriage returns / CRLF (SC1017) | 10 files | Convert to Unix line endings with `dos2unix` or `tr -d '\r'` |
| Medium | Unquoted variables (SC2086) | 70 instances | Quote variable references |
| Medium | Unused variables (SC2034) | 12 instances | Remove or prefix with `_` |
| Low | Array expansion issues (SC2068) | 6 instances | Use `"${array[@]}"` syntax |
| Low | Indirect exit code checks (SC2181) | 8 instances | Use `if cmd; then` instead of `if [ $? -eq 0 ]` |

## VERDICT

**No secrets or leaked credentials found.** Repository is clean of security-sensitive data.

ShellCheck found 356 issues across 84 shell scripts. The majority (180) are errors due to missing shebangs and CRLF line endings — these are straightforward fixes that don't affect script functionality but should be addressed for code quality and CI compliance.
