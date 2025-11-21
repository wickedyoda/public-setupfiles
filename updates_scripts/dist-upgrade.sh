#!/bin/bash

# Backup existing sources
sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup.$(date +%F-%H%M)

# Detect OS ID and VERSION_CODENAME
ID=$(grep -oP '(?<=^ID=).+' /etc/os-release)
CODENAME=$(grep -oP '(?<=^VERSION_CODENAME=).+' /etc/os-release)

echo "Detected OS: $ID"
echo "Detected Codename: $CODENAME"

# Debian Only
if [ "$ID" == "debian" ]; then
    echo "Debian system detected."

    # Check if we're on Bookworm
    if [ "$CODENAME" != "bookworm" ]; then
        echo "This script only upgrades Debian 12 (Bookworm). Current version is: $CODENAME"
        exit 1
    fi

    echo "Upgrading Debian 12 → Debian 13 (Trixie)..."
    echo "Updating sources.list to Trixie..."

    sudo tee /etc/apt/sources.list >/dev/null << EOF
deb http://deb.debian.org/debian trixie main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian trixie main contrib non-free non-free-firmware

deb http://deb.debian.org/debian trixie-updates main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian trixie-updates main contrib non-free non-free-firmware

deb http://deb.debian.org/debian-security trixie-security main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian-security trixie-security main contrib non-free non-free-firmware
EOF

else
    echo "This script only supports Debian. Exiting."
    exit 1
fi

echo "=== Running apt update ==="
sudo apt update

echo "=== Starting full upgrade ==="
sudo apt full-upgrade -y
sudo apt dist-upgrade -y

echo "=== Cleaning system ==="
sudo apt autoremove -y
sudo apt clean -y
sudo apt autopurge -y

echo ""
echo "======================================================"
echo " Debian upgrade to TRIXIE is complete!"
echo " It is recommended to reboot now: sudo reboot"
echo "======================================================"