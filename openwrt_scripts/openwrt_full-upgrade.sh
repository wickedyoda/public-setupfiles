#!/bin/sh

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Use sudo or run as root."
    exit 1
fi

echo "Starting full OpenWRT upgrade using opkg..."

# Step 1: Update package lists
echo "Updating package lists..."
opkg update

# Step 2: List upgradable packages
echo "Listing upgradable packages..."
opkg list-upgradable

# Step 3: Upgrade all installed packages
echo "Upgrading installed packages..."
opkg list-upgradable | cut -f1 -d ' ' | xargs -r opkg upgrade

# Step 4: Remove unnecessary packages
echo "Removing unnecessary packages..."
opkg remove --autoremove

# Step 5: Clean package cache
echo "Cleaning up package cache..."
opkg clean

# Step 6: Restart the device (optional)
echo "Upgrade complete. A reboot is recommended."
read -p "Do you want to reboot now? (y/N): " REBOOT
if [ "$REBOOT" = "y" ] || [ "$REBOOT" = "Y" ]; then
    echo "Rebooting..."
    reboot
else
    echo "Reboot skipped. You may need to restart manually."
fi

echo "OpenWRT full upgrade completed!"

