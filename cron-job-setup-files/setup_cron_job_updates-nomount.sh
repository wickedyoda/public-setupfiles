#!/bin/bash

# Script: setup_auto_updates.sh
# Description: Script to set up automatic system updates using cron

# Update package lists and install cron
sudo apt update
sudo apt install cron -y

# Enable and start the cron service
sudo systemctl enable cron
sudo systemctl start cron

# Stop the cron service to make changes
sudo systemctl stop cron

# Add the update and upgrade cron job to /etc/cron.d/
# Old line that doesnt work
#   echo 'MAILTO="alerts@tyates.one"
#   0 */6 * * * root apt-get update && apt-get -y -d full-upgrade && apt-get autoremove -y && sudo apt-get clean -y && sudo apt-get purge -y' | sudo tee /etc/cron.d/auto_updates

# Add the update and upgrade cron job to /etc/cron.d/auto_updates
echo 'MAILTO="alerts@tyates.one"
0 */6 * * * root apt-get update && apt-get -y -d full-upgrade && apt-get autoremove -y && sudo apt-get clean -y && sudo apt-get purge -y' | sudo tee /etc/cron.d/auto_updates

# Restart the cron service to apply the new cron job
sudo systemctl start cron
