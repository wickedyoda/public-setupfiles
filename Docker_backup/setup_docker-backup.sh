#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- CONFIG ---
SRC_SCRIPT="${SCRIPT_DIR}/docker-backup.sh"
DEST_DIR="/root/docker"
DEST_SCRIPT="${DEST_DIR}/docker-backup.sh"
CRON_JOB_FILE="/etc/cron.d/docker-backup"
LOG_FILE="/var/log/docker_backup.log"

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run this script as root."
  exit 1
fi

mkdir -p "${DEST_DIR}"

install -m 755 "${SRC_SCRIPT}" "${DEST_SCRIPT}"
echo "Installed ${DEST_SCRIPT}"

cat > "${CRON_JOB_FILE}" <<EOF
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# Run every 3 hours
0 */3 * * * root ${DEST_SCRIPT} >> ${LOG_FILE} 2>&1
EOF

chmod 644 "${CRON_JOB_FILE}"
echo "Installed ${CRON_JOB_FILE}"
