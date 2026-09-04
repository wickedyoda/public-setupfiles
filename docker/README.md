# Docker Configuration

Docker and Docker Compose setup files.

---

## Overview

This directory contains Docker installation scripts and compose file examples.

## Installation Scripts

| Script | Platform |
|--------|----------|
| `install_docker_debian.sh` | Debian/Ubuntu |
| `install_docker_ubuntu.sh` | Ubuntu only |

## Docker Compose Examples

| File | Service |
|------|---------|
| `jellyfin-docker-compose.yml` | Media server |
| `portainer/portainer-installscript.sh` | Container management |
| `portainer/update-portainer.sh` | Update Portainer |

## Portainer

### Install

```bash
# Run the install script
sudo ./docker/portainer/portainer-installscript.sh
```

Manually:
```bash
docker volume create portainer_data
docker run -d -p 8099:8000 -p 9443:9443 \
  --name portainer \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce:latest
```

### Update

```bash
docker stop portainer
docker rm portainer
docker pull portainer/portainer-ce:latest
./docker/portainer/update-portainer.sh
```

## Jellyfin

See `docker/jellyfin-docker-compose.yml` for the full compose file.

**Ports:**
- `8096` — HTTP
- `8920` — HTTPS (optional)
- `7359/1900` — UPnP (optional)

**Edit before running:**
- Volume paths for config, cache, media
- `JELLYFIN_PublishedServerUrl` for your domain

## Notes

- Run Docker installation as root
- Add user to docker group after install: `sudo usermod -aG docker $USER`
- Log out and back in for group changes