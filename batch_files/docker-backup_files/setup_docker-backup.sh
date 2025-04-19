#!/bin/bash

# --- CONFIG ---
SRC_SCRIPT="./docker-backup.sh"
DEST_SCRIPT="/root/docker/docker-backup.sh"
CRON_JOB_FILE="/etc/cron.d/docker-backup"
LOG_FILE="/var/log/docker-backup-log"

# --- ENSURE /root/docker EXISTS ---
mkdir -p /root/docker

# --- COPY OR REPLACE SCRIPT ---
cp "${SRC_SCRIPT}" "${DEST_SCRIPT}" || {
    echo "❌ Failed to copy ${SRC_SCRIPT} to ${DEST_SCRIPT}"
    exit 1
}

chmod +x "${DEST_SCRIPT}"
echo "✅ Script installed to ${DEST_SCRIPT} and made executable."

# --- WRITE CRON JOB WITH RANDOM DELAY UP TO 2 HOURS ---
cat > "${CRON_JOB_FILE}" <<EOF
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# Run daily with a random delay of up to 7200 seconds (2 hours)
0 2 * * * root sleep \$((RANDOM % 7200)) && ${DEST_SCRIPT} >> ${LOG_FILE} 2>&1
EOF

chmod 644 "${CRON_JOB_FILE}"
echo "✅ Cron job installed in ${CRON_JOB_FILE}"