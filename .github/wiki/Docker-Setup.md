# Docker Setup

Docker configuration, installation scripts, and backup utilities.

---

## Docker Installation Scripts

### `docker/install_docker_debian.sh`

Debian-based Docker Engine installation.

**Usage:**
```bash
sudo ./install_docker_debian.sh
```

**Includes:**
- Docker Engine (docker-ce)
- Docker Compose plugin (v2)
- Optional: Adds current user to docker group

**Post-install:**
```bash
# Log out and back in, or run:
newgrp docker
```

---

### `docker/install_docker_ubuntu.sh`

Ubuntu-specific Docker installation.

**Usage:**
```bash
sudo ./install_docker_ubuntu.sh
```

**Same functionality as debian script with Ubuntu package names.**

---

## Docker Compose Examples

### `docker/jellyfin-docker-compose.yml`

Media server configuration.

**Key settings:**
- Ports: 8096 (web), 8920 (HTTPS), 7359/1900 (UPnP)
- Volumes: config, cache, media
- Published URL: `http://docker2`

**Usage:**
```bash
docker compose up -d
```

**Edit before running:**
- Update `volumes` paths to match your system
- Adjust `JELLYFIN_PublishedServerUrl` for your domain

---

### `docker/portainer/portainers-installscript.sh`

Portainer container installation.

**Usage:**
```bash
sudo ./portainers-installscript.sh
```

**Creates:**
- Portainer data volume
- Portainer CE container on port 8099 (UI), 9443 (HTTPS)

---

### `docker/portainer/update-portainer.sh`

Update Portainer to latest version.

**Usage:**
```bash
sudo ./update-portainer.sh
```

**What it does:**
1. Pulls `portainer/portainer-ce:latest`
2. Restarts the container

---

## Docker Backup

### Location: `Docker_backup/`

**Scripts:**
| Script | Purpose |
|--------|---------|
| `docker-backup.sh` | Main backup script |
| `setup_docker-backup.sh` | Install backup + cron |
| `correct_docker-backup.sh` | Fix older installs |
| `update_docker-backup.sh` | Upgrade existing |

**Backup Contents:**
```
/mnt/naspublic/docker-backup/{hostname}/{month}/{date}/
├── /root/docker
├── /opt/docker
├── /var/lib/docker/volumes
└── /home/traver/docker
```

**Schedule:** Every 3 hours

**Retention:** 14 days

**Usage:**
```bash
# First time setup
sudo ./setup_docker-backup.sh

# Update existing install
sudo ./update_docker-backup.sh
```

---

## Docker Remote API

### `docker_stuff/setup-docker-remote-api.sh`

Enable Docker TCP API for remote monitoring (e.g., Uptime Kuma).

**Usage:**
```bash
# Basic (insecure - listens on all interfaces)
sudo bash setup-docker-remote-api.sh

# With IP restriction (secure)
sudo bash setup-docker-remote-api.sh --allow-ip 10.0.84.50
```

**Warning:** This exposes the Docker API over unencrypted TCP. Only use on trusted networks with IP restrictions.

**Default port:** 2375

---

## Docker Cleanup

### `docker_stuff/docker_cleanup_updates.sh`

Combined update and cleanup script.

**What it does:**
1. Pulls setup scripts from GitHub
2. Runs system updates
3. Prunes unused Docker images
4. Prunes unused Docker networks
5. Removes stopped containers
6. Clears build cache

**Usage:**
```bash
sudo ./docker_cleanup_updates.sh
```