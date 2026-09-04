# Uptime Updates

Uptime Kuma container monitoring synchronization bot.

---

## Overview

The uptime-updates bot keeps Docker container IDs synchronized with Uptime Kuma monitors when containers are recreated.

## Files

| File | Description |
|------|-------------|
| `uptime-bot.py` | Main Python bot |
| `config.yml` | Uptime Kuma API configuration |
| `container-monitor-map.yaml` | Container-to-monitor mappings |
| `requirements.txt` | Python dependencies |
| `setup-update_uptime-bot.sh` | Installation script |
| `export-watchtower-bundle.sh` | Create Docker bundle |

## Installation

### Using Setup Script

```bash
sudo bash uptime-updates/setup-update_uptime-bot.sh
```

### Options

```bash
sudo bash setup-update_uptime-bot.sh \
  --install-dir /opt/uptime-updates \
  --service-name uptime-updates-bot.service \
  --user root
```

---

## Configuration

### config.yml

```yaml
uptime_kuma:
  url: "http://127.0.0.1:3001"
  api_key: "YOUR_API_KEY_HERE"

bot:
  dry_run: false
  request_timeout_seconds: 10
  poll_interval_seconds: 60
```

### container-monitor-map.yaml

```yaml
mappings:
  - name: "media-server jellyfin"
    enabled: true
    host_api: "tcp://10.0.84.21:2375"
    container_name: "jellyfin"
    uptime_monitor_id: 21
    expected_uptime_type: "docker"
```

---

## Docker Standalone Deployment

See `uptime-updates/watchtower-export/` for Docker Compose files:
- `docker-compose.watchtower-uptime-sync.yml`
- `docker-compose.watchtower-embedded.yml`

---

## Usage with Docker Remote API

### Enable Docker TCP API

```bash
# On each Docker host
sudo bash /path/to/public-setupfiles/docker_stuff/setup-docker-remote-api.sh --allow-ip 10.0.84.50
```

### Update Monitor Mapping

Edit `container-monitor-map.yaml` and re-run:
```bash
sudo bash setup-update_uptime-bot.sh
```

The bot reloads configuration each cycle, so most changes apply without restart.

---

## Watchtower Export

### Files

| File | Purpose |
|------|---------|
| `Dockerfile` | Bot container image |
| `requirements.txt` | Python deps |
| `docker-compose.watchtower-uptime-sync.yml` | Separate containers |
| `docker-compose.watchtower-embedded.yml` | Embedded mode |

### Build Bundle

```bash
cd uptime-updates
sudo bash export-watchtower-bundle.sh
```

Creates timestamped tar.gz for sharing.

---

## Monitoring

```bash
# Check service status
systemctl status uptime-updates-bot

# View logs
journalctl -u uptime-updates-bot -f
```