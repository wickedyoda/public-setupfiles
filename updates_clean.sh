#!/bin/bash
#
# updates_clean.sh — hardened automatic system update + cleanup
# Cleaned-up version of public-setupfiles/updates_scripts/updates.sh
# Changes vs original:
#   - timestamped logging to /var/log/auto_updates.log
#   - one source of truth (this script is what cron calls)
#   - no-op `apt-get purge -y` (no target) removed
#   - `full-upgrade -y` instead of bare `upgrade -y` so it actually applies
#     (original cron used `-d` download-only, which never installed)
#   - `autopurge` on Debian 11+ for true orphan cleanup
#   - guards so a single failure doesn't abort the whole run silently
#   - safe to run by hand:  sudo ./updates_clean.sh
#
# Intended schedule (see setup_cron_clean.sh): every 6h, download+apply, cleanup.

set -u

LOG="/var/log/auto_updates.log"
exec > >(tee -a "$LOG") 2>&1

echo "============================================================"
echo "auto-update started: $(date '+%Y-%m-%d %H:%M:%S')"
echo "host: $(hostname)  user: $(whoami)"
echo "============================================================"

# 1) Refresh package lists
echo "[*] apt update"
apt-get update -y || echo "[!] apt update returned non-zero (continuing)"

# 2) Apply upgrades (download + install). full-upgrade handles removals.
echo "[*] apt full-upgrade"
apt-get full-upgrade -y || echo "[!] full-upgrade returned non-zero (continuing)"

# 3) Remove orphaned packages
echo "[*] apt autoremove"
apt-get autoremove -y || echo "[!] autoremove returned non-zero"

# 4) Purge configs of removed packages (Debian 11+)
if apt-get --version | grep -q "autopurge"; then
    echo "[*] apt autopurge"
    apt-get autopurge -y || echo "[!] autopurge returned non-zero"
fi

# 5) Clear the local cache
echo "[*] apt clean"
apt-get clean -y || echo "[!] clean returned non-zero"

echo "[+] auto-update finished: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""
