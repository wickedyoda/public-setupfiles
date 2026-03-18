#!/usr/bin/env bash
set -euo pipefail

# =========================
# Docker Backup Script
# =========================

# Backup destination
HOSTNAME="$(hostname -s)"
BACKUP_BASE="/mnt/naspublic/docker-backups/${HOSTNAME}"

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

# Date/time foldering
DATE_STAMP="$(date '+%Y-%m-%d')"
TIME_STAMP="$(date '+%H-%M-%S')"
BACKUP_DIR="${BACKUP_BASE}/${DATE_STAMP}"

log() {
  echo "[$(date '+%F %T')] $*" | tee -a "$LOG_FILE"
}

archive_name_for_path() {
  local path="$1"
  echo "${path#/}" | tr '/' '_'
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

create_archive() {
  local path="$1"
  local archive_name
  local archive_path
  local parent_dir
  local base_name

  if [[ ! -e "$path" ]]; then
    log "Warning: source path missing: $path"
    return 0
  fi

  archive_name="$(archive_name_for_path "$path")"
  archive_path="${BACKUP_DIR}/${TIME_STAMP}_${archive_name}.tar.gz"
  parent_dir="$(dirname "$path")"
  base_name="$(basename "$path")"

  log "Creating archive ${archive_path} from ${path}"
  tar --xattrs --acls --numeric-owner -czpf "$archive_path" -C "$parent_dir" "$base_name" >>"$LOG_FILE" 2>&1
}

main() {
  log "========================================"
  log "Starting Docker backup"

  mkdir -p "$BACKUP_BASE"
  mkdir -p "$BACKUP_DIR"

  if [[ "$STOP_CONTAINERS" == "true" ]]; then
    stop_containers
  fi

  log "Creating separate compressed backups in $BACKUP_DIR"
  for path in "${SOURCE_PATHS[@]}"; do
    create_archive "$path"
  done

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
