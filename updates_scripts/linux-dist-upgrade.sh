#!/bin/bash
set -e

echo "=== Universal Dist-Upgrade Script ==="

# Backup sources before doing anything
BACKUP_DATE=$(date +%F-%H%M)
sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup.$BACKUP_DATE 2>/dev/null || true

# Detect OS + Version
ID=$(grep -oP '(?<=^ID=).+' /etc/os-release)
VERSION_CODENAME=$(grep -oP '(?<=^VERSION_CODENAME=).+' /etc/os-release)
UBUNTU_CODENAME=$(grep -oP '(?<=^UBUNTU_CODENAME=).+' /etc/os-release)
PRETTY=$(grep -oP '(?<=^PRETTY_NAME=").+(?=")' /etc/os-release)

echo "Detected OS: $ID"
echo "Detected Version: $VERSION_CODENAME"
echo "Pretty Name: $PRETTY"
echo ""

###############################################################################
# Debian Upgrade Path
###############################################################################

if [ "$ID" == "debian" ]; then
    echo "=== Debian detected ==="

    # Map old → new
    if [ "$VERSION_CODENAME" == "bullseye" ]; then
        TARGET="bookworm"
    elif [ "$VERSION_CODENAME" == "bookworm" ]; then
        TARGET="trixie"
    else
        echo "⚠ Unknown Debian codename: $VERSION_CODENAME"
        echo "Exiting for safety."
        exit 1
    fi

    echo "Upgrading Debian $VERSION_CODENAME → $TARGET"

    sudo tee /etc/apt/sources.list >/dev/null << EOF
deb http://deb.debian.org/debian $TARGET main contrib non-free non-free-firmware
deb http://deb.debian.org/debian $TARGET-updates main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security $TARGET-security main contrib non-free non-free-firmware
EOF

fi

###############################################################################
# Ubuntu Upgrade Path
###############################################################################

if [ "$ID" == "ubuntu" ]; then
    echo "=== Ubuntu detected ==="

    # Map current → target LTS (safe path)
    if [ "$UBUNTU_CODENAME" == "jammy" ]; then
        TARGET="noble"   # 22.04 → 24.04
    elif [ "$UBUNTU_CODENAME" == "noble" ]; then
        TARGET="noble"   # Already latest
    else
        echo "⚠ Unsupported Ubuntu release: $UBUNTU_CODENAME"
        echo "Supported: jammy → noble"
        exit 1
    fi

    echo "Upgrading Ubuntu $UBUNTU_CODENAME → $TARGET"

    sudo tee /etc/apt/sources.list >/dev/null << EOF
deb http://archive.ubuntu.com/ubuntu/ $TARGET main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu/ $TARGET-updates main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu/ $TARGET-backports main restricted universe multiverse
deb http://security.ubuntu.com/ubuntu $TARGET-security main restricted universe multiverse
EOF

fi

###############################################################################
# Kali Linux Upgrade Path
###############################################################################

if [ "$ID" == "kali" ]; then
    echo "=== Kali Rolling detected ==="
    echo "Switching to latest Rolling repositories"

    sudo tee /etc/apt/sources.list >/dev/null << EOF
deb http://http.kali.org/kali kali-rolling main contrib non-free non-free-firmware
EOF

fi

###############################################################################
# Upgrade Execution
###############################################################################

echo ""
echo "=== Updating package lists ==="
sudo apt update

echo "=== Full system upgrade ==="
sudo apt full-upgrade -y || sudo apt --fix-broken install -y

echo "=== Dist-upgrade ==="
sudo apt dist-upgrade -y

echo "=== Cleaning up ==="
sudo apt autoremove -y
sudo apt clean -y
sudo apt autopurge -y

echo ""
echo "============================================"
echo " System successfully upgraded!"
echo " A reboot is recommended: sudo reboot"
echo "============================================"