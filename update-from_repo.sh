#!/bin/sh

# Ensure script is run as root
if [ "$(id -u)" -ne 0 ]; then
   echo "This script must be run as root."
   exit 1
fi

# Function to auto-install git dynamically based on platform
install_git() {
    if command -v apt-get >/dev/null 2>&1; then
        echo "Debian detected. Installing git..."
        apt-get update && apt-get install -y git
    elif command -v opkg >/dev/null 2>&1; then
        echo "OpenWrt detected. Installing git..."
        opkg update && opkg install git git-http
    else
        echo "Error: Neither apt nor opkg found."
        exit 1
    fi
}

# Auto-install Git if missing instead of failing silently
if ! command -v git >/dev/null 2>&1; then
    install_git
fi

REMOTE_REPO="https://github.com/wickedyoda/public-setupfiles.git"
LOCAL_DIR="./public-setupfiles"

if [ -d "$LOCAL_DIR" ] && [ "$(ls -A "$LOCAL_DIR" 2>/dev/null)" ]; then
    echo "Cleaning old directory..."
    rm -rf "$LOCAL_DIR"
fi

echo "Cloning repository..."
git clone "$REMOTE_REPO" "$LOCAL_DIR"
chmod -R 755 "$LOCAL_DIR"
echo "Done!"