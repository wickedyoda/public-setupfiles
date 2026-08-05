#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

DEST_DIR="/root/docker"
DEST_SCRIPT="${DEST_DIR}/docker-backup.sh"
CRON_JOB_FILE="/etc/cron.d/docker-backup"
LOG_FILE="/var/log/docker_backup.log"
CRON_MATCH='docker-backup\.sh|docker_backup\.log|docker-backup-log'
FILES_TO_INSTALL=(
  "docker-backup.sh"
  "setup_docker-backup.sh"
  "correct_docker-backup.sh"
  "update_docker-backup.sh"
)

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run this script as root."
  exit 1
fi

remove_legacy_cron_jobs() {
  local cron_file
  while IFS= read -r cron_file; do
    rm -f "$cron_file"
    echo "Removed legacy cron file ${cron_file}"
  done < <(grep -El "${CRON_MATCH}" /etc/cron.d/* 2>/dev/null || true)

  if [[ -f /etc/crontab ]] && grep -Eq "${CRON_MATCH}" /etc/crontab; then
    grep -Ev "${CRON_MATCH}" /etc/crontab >/tmp/docker-backup-etc-crontab.cleaned || true
    install -m 644 /tmp/docker-backup-etc-crontab.cleaned /etc/crontab
    rm -f /tmp/docker-backup-etc-crontab.cleaned
    echo "Removed legacy Docker backup entries from /etc/crontab"
  fi

  if crontab -l -u root >/tmp/docker-backup-root-crontab 2>/dev/null; then
    grep -Ev "${CRON_MATCH}" /tmp/docker-backup-root-crontab >/tmp/docker-backup-root-crontab.cleaned || true
    crontab -u root /tmp/docker-backup-root-crontab.cleaned
    rm -f /tmp/docker-backup-root-crontab /tmp/docker-backup-root-crontab.cleaned
    echo "Removed legacy Docker backup entries from root crontab"
  fi
}

remove_legacy_cron_jobs

mkdir -p "${DEST_DIR}"

install_scripts() {
  local file
  for file in "${FILES_TO_INSTALL[@]}"; do
    install -m 755 "${SCRIPT_DIR}/${file}" "${DEST_DIR}/${file}"
    echo "Installed ${DEST_DIR}/${file}"
  done
}

install_scripts

cat > "${CRON_JOB_FILE}" <<EOF
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# Run every 3 hours
0 */3 * * * root ${DEST_SCRIPT} >> ${LOG_FILE} 2>&1
EOF

chmod 644 "${CRON_JOB_FILE}"
echo "Installed ${CRON_JOB_FILE}"
echo "Docker backup scripts were updated and will run every 3 hours."
