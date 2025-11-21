#!/bin/bash

# Backup of existing sources.list file
sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup

# Create variable from /etc/os-release file to get ID
ID=$(grep -oP '(?<=^ID=).+' /etc/os-release)

echo "Detected system: $ID"

###############################################################################
# Debian (Upgrades to TRIXIE — latest stable)
###############################################################################
if [ "$ID" == "debian" ]; then
    echo "Debian system detected."
    echo "Updating sources.list for TRIXIE (Debian 13)..."

sudo tee /etc/apt/sources.list >/dev/null << EOF
deb http://deb.debian.org/debian trixie main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian trixie main contrib non-free non-free-firmware

deb http://deb.debian.org/debian trixie-updates main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian trixie-updates main contrib non-free non-free-firmware

deb http://security.debian.org/debian-security trixie-security main contrib non-free non-free-firmware
deb-src http://security.debian.org/debian-security trixie-security main contrib non-free non-free-firmware
EOF

fi

###############################################################################
# Ubuntu (Upgrades to Noble — 24.04 LTS)
###############################################################################
if [ "$ID" == "ubuntu" ]; then
    echo "Ubuntu system detected."
    echo "Updating sources.list for Noble 24.04 LTS..."

sudo tee /etc/apt/sources.list >/dev/null << EOF
deb http://archive.ubuntu.com/ubuntu/ noble main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu/ noble-updates main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu/ noble-backports main restricted universe multiverse
deb http://security.ubuntu.com/ubuntu noble-security main restricted universe multiverse
EOF

fi

###############################################################################
# Kali (Always rolling)
###############################################################################
if [ "$ID" == "kali" ]; then
    echo "Kali Linux detected."
    echo "Switching to kali-rolling repo..."

sudo tee /etc/apt/sources.list >/dev/null << EOF
deb http://http.kali.org/kali kali-rolling main contrib non-free non-free-firmware
EOF

fi

###############################################################################
# APT upgrade operations
###############################################################################

echo "Running apt update..."
sudo apt update

echo "Running full upgrade..."
sudo apt full-upgrade -y || sudo apt --fix-broken install -y

echo "Running dist-upgrade..."
sudo apt dist-upgrade -y

echo "Cleaning system..."
sudo apt autoremove -y
sudo apt clean -y
sudo apt autopurge -y

echo "======================================="
echo " System update and cleanup complete!"
echo " A reboot is recommended: sudo reboot"
echo "======================================="