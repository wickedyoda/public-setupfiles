#!/bin/bash

# Script: setup_auto_updates.sh
# Description: Configure automatic system updates via cron on Debian 12

# Exit immediately on error
set -e

# Update package lists and install cron
sudo apt update
sudo apt install -y cron

# Enable and start the cron service
sudo systemctl enable cron
sudo systemctl restart cron

# Write the cron job to /etc/cron.d/auto_updates properly using EOF
sudo tee /etc/cron.d/auto_updates > /dev/null << 'EOF'
MAILTO="alerts@tyates.one"
0 */6 * * * root apt-get update && apt-get -y -d full-upgrade && apt-get autoremove -y && apt-get clean -y && apt-get purge -y
EOF

# Set proper permissions
sudo chmod 644 /etc/cron.d/auto_updates
sudo chown root:root /etc/cron.d/auto_updates

echo "[✓] Auto update cron job installed. Runs every 6 hours."