# Uptime Updates Bot

This directory contains a bot that keeps Uptime Kuma Docker monitor container IDs in sync when containers are recreated.

## Files

- `config.yml` - Uptime Kuma URL, API key, and bot behavior settings.
- `container-monitor-map.yaml` - Docker host/container to Uptime monitor ID mappings.
- `uptime-bot.py` - Continuous sync bot runner.
- `setup-update_uptime-bot.sh` - Installer/updater for Linux systemd.
- `requirements.txt` - Python dependencies used by the bot virtualenv.

## Requirements

- Linux host with systemd
- Root or sudo access
- Docker remote API reachable for each mapped host (`host_api`)

## Configure

1. Edit `config.yml`:
   - Set `uptime_kuma.url`
   - Set `uptime_kuma.api_key`
   - Optional: adjust `bot.poll_interval_seconds`

2. Edit `container-monitor-map.yaml`:
   - Add one mapping per container
   - Set `host_api`, `container_name`, and `uptime_monitor_id`

## Install And Start Service

Run from this directory:

```bash
sudo bash setup-update_uptime-bot.sh
```

What this does:
- Installs/updates files under `/opt/uptime-updates`
- Ensures compatible Python is available (for `uptime-bot.py`)
- Creates virtualenv and installs dependencies from `requirements.txt`
- Writes/updates systemd service
- Enables service on boot and restarts it

## Update After Changes

After editing files in this directory, re-run:

```bash
sudo bash setup-update_uptime-bot.sh
```

The installer is idempotent and acts as both installer and updater.

By default on update:
- Existing live `/opt/uptime-updates/config.yml` is preserved
- Existing live `/opt/uptime-updates/container-monitor-map.yaml` is preserved

Use overwrite flags only when you want to replace live files from repo copies.

## Common Commands

```bash
systemctl status uptime-updates-bot.service
journalctl -u uptime-updates-bot.service -f
systemctl restart uptime-updates-bot.service
systemctl stop uptime-updates-bot.service
systemctl disable uptime-updates-bot.service
```

## Installer Options

```bash
sudo bash setup-update_uptime-bot.sh --help
```

Useful options:
- `--install-dir PATH`
- `--service-name NAME`
- `--user USER`
- `--group GROUP`
- `--no-enable`
- `--no-start`
- `--min-python-version 3.9`
- `--overwrite-config`
- `--overwrite-map`
- `--overwrite-all`
- `--dry-run`

## Notes

- If using Docker TCP API (`tcp://host:2375`), secure network access appropriately.
- `expected_uptime_type: docker` in mapping items helps prevent accidental updates to non-docker monitors.
- The bot reloads `config.yml` and `container-monitor-map.yaml` each cycle, so most config changes do not require service restart.
