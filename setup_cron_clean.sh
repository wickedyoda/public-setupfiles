#!/bin/bash
#
# setup_cron_clean.sh — install updates_clean.sh as a system cron job
# Cleaned-up version of public-setupfiles/cron-job-setup-files/setup_cron_job_updates.sh
#
# Fixes vs original:
#   - cron actually CALLS updates_clean.sh (one source of truth) instead of an
#     inline one-liner that diverged from updates.sh
#   - removed no-op `apt-get purge -y` (no target)
#   - hourly `mount -a` kept but isolated so a mount error can't break updates
#   - script is copied to /usr/local/sbin so the cron path is stable
#   - MAILTO left as a comment — enable only if the host has a working MTA
#
# Usage (as root):  sudo ./setup_cron_clean.sh

set -u

SCRIPT_SRC="$(cd "$(dirname "$0")" && pwd)/updates_clean.sh"
INSTALL_PATH="/usr/local/sbin/updates_clean.sh"

# 1) Ensure cron is present
echo "[*] installing cron (if missing)"
apt-get update -y >/dev/null 2>&1
apt-get install -y cron

# 2) Install the worker script to a stable location
echo "[*] installing $INSTALL_PATH"
install -m 0755 "$SCRIPT_SRC" "$INSTALL_PATH"

# 3) Enable + start cron
systemctl enable cron
systemctl restart cron

# 4) Write the cron.d job (calls the installed script)
echo "[*] writing /etc/cron.d/auto_updates"
cat > /etc/cron.d/auto_updates <<EOF
# Managed by setup_cron_clean.sh — runs updates_clean.sh
# Uncomment MAILTO only if this host has a working MTA:
# MAILTO="alerts@tyates.one"
0 */6 * * * root $INSTALL_PATH >> /var/log/auto_updates.log 2>&1
# Keep mounts healthy (isolated so a mount error can't affect updates)
5 */1 * * * root mount -a >> /var/log/auto_updates.log 2>&1
EOF

echo "[+] done. Job installed:"
echo "    every 6h: $INSTALL_PATH"
echo "    every 1h: mount -a"
echo "    log: /var/log/auto_updates.log"
