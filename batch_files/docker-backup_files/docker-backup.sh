#!/bin/bash

# --- CONFIG ---
SYSTEM_NAME="$(hostname)"
BACKUP_DATE="$(date +%Y-%m-%d)"
DEST_DIR="/mnt/naspublic/docker-backups/${SYSTEM_NAME}"
BACKUP_FILE="docker-backup-${SYSTEM_NAME}-${BACKUP_DATE}.tar.gz"
TMP_BACKUP="/tmp/${BACKUP_FILE}"
LOG_FILE="/var/log/docker-backup-log"

# --- START LOGGING ---
{
echo "----- $(date '+%F %T') -----"
echo "🔄 Starting backup for system: $SYSTEM_NAME"

# --- CREATE DEST DIR IF NEEDED ---
mkdir -p "${DEST_DIR}" || echo "⚠️ Could not create destination directory: ${DEST_DIR}"

# --- CREATE COMPRESSED BACKUP, IGNORING READ ERRORS ---
echo "📦 Creating compressed backup..."
tar -czf "${TMP_BACKUP}" --ignore-failed-read /root/docker /home/traver/docker

# --- COPY TO DESTINATION ---
echo "📁 Copying to: ${DEST_DIR}/"
cp "${TMP_BACKUP}" "${DEST_DIR}/" || echo "❌ Failed to copy backup to destination."

# --- CLEANUP TEMP FILE ---
rm -f "${TMP_BACKUP}" || echo "⚠️ Failed to remove temporary file."

# --- DELETE FILES OLDER THAN 15 DAYS ---
echo "🧹 Cleaning up backups older than 15 days..."
find "${DEST_DIR}" -name "docker-backup-*.tar.gz" -type f -mtime +15 -exec rm -f {} \;

echo "✅ Backup complete: ${DEST_DIR}/${BACKUP_FILE}"
echo
} >> "${LOG_FILE}" 2>&1