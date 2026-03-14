#!/usr/bin/env bash
set -euo pipefail

# =========================
# Docker Backup Script
# =========================

# Backup destination
BACKUP_BASE="/mnt/backup/docker-backups"

# What to back up
SOURCE_PATHS=(
  "/root/docker"
  "/home/traver/docker"
  "/var/lib/docker/volumes"
)

# Retention in days
RETENTION_DAYS=7

# Log file
LOG_FILE="/var/log/docker_backup.log"

# Stop containers during backup? true/false
STOP_CONTAINERS="false"

# Docker compose search roots for optional stop/start
COMPOSE_DIRS=(
  "/root/docker"
  "/home/traver/docker"
)

# Timestamp
TIMESTAMP="$(date '+%Y-%m-%d_%H-%M-%S')"
BACKUP_DIR="${BACKUP_BASE}/${TIMESTAMP}"

log() {
  echo "[$(date '+%F %T')] $*" | tee -a "$LOG_FILE"
}

start_containers() {
  log "Starting Docker Compose stacks..."
  for dir in "${COMPOSE_DIRS[@]}"; do
    if [[ -d "$dir" ]]; then
      while IFS= read -r -d '' compose_file; do
        compose_path="$(dirname "$compose_file")"
        log "Starting stack in $compose_path"
        docker compose -f "$compose_file" up -d >>"$LOG_FILE" 2>&1 || log "Warning: failed to start stack in $compose_path"
      done < <(find "$dir" -type f \( -name "docker-compose.yml" -o -name "compose.yml" -o -name "docker-compose.yaml" -o -name "compose.yaml" \) -print0)
    fi
  done
}

stop_containers() {
  log "Stopping Docker Compose stacks..."
  for dir in "${COMPOSE_DIRS[@]}"; do
    if [[ -d "$dir" ]]; then
      while IFS= read -r -d '' compose_file; do
        compose_path="$(dirname "$compose_file")"
        log "Stopping stack in $compose_path"
        docker compose -f "$compose_file" down >>"$LOG_FILE" 2>&1 || log "Warning: failed to stop stack in $compose_path"
      done < <(find "$dir" -type f \( -name "docker-compose.yml" -o -name "compose.yml" -o -name "docker-compose.yaml" -o -name "compose.yaml" \) -print0)
    fi
  done
}

cleanup_old_backups() {
  log "Removing backups older than ${RETENTION_DAYS} days from ${BACKUP_BASE}"
  find "$BACKUP_BASE" -mindepth 1 -maxdepth 1 -type d -mtime +"$RETENTION_DAYS" -exec rm -rf {} \; >>"$LOG_FILE" 2>&1 || true
}

main() {
  log "========================================"
  log "Starting Docker backup"

  mkdir -p "$BACKUP_BASE"
  mkdir -p "$BACKUP_DIR"

  for path in "${SOURCE_PATHS[@]}"; do
    if [[ ! -e "$path" ]]; then
      log "Warning: source path missing: $path"
    fi
  done

  if [[ "$STOP_CONTAINERS" == "true" ]]; then
    stop_containers
  fi

  log "Running rsync backup to $BACKUP_DIR"
  rsync -aHAX --delete \
    /root/docker \
    /home/traver/docker \
    /var/lib/docker/volumes \
    "$BACKUP_DIR"/ >>"$LOG_FILE" 2>&1

  log "Backup sizes:"
  du -sh "$BACKUP_DIR" >>"$LOG_FILE" 2>&1 || true

  if [[ "$STOP_CONTAINERS" == "true" ]]; then
    start_containers
  fi

  cleanup_old_backups

  log "Docker backup completed successfully"
  log "========================================"
}

main "$@"