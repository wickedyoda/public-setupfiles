#!/bin/sh
set -euo pipefail

# Ensure script is run as root
if [ "$(id -u)" -ne 0 ]; then
   echo "This script must be run as root."
   exit 1
fi

# Auto-install Git if missing instead of failing silently
if ! command -v git >/dev/null 2>&1; then
    if command -v apt-get >/dev/null 2>&1; then
        echo "Debian detected. Installing git..."
        apt-get update && apt-get install -y git
    elif command -v opkg >/dev/null 2>&1; then
        echo "OpenWrt detected. Installing git..."
        opkg update && opkg install git git-http
    else
        echo "Error: Neither apt-get nor opkg found to install git."
        exit 1
    fi
    # Verify git is actually available after install
    if ! command -v git >/dev/null 2>&1; then
        echo "Error: Git installation failed. git is not available."
        exit 1
    fi
fi

REMOTE_REPO="https://github.com/wickedyoda/public-setupfiles.git"
LOCAL_DIR="public-setupfiles"

# If we're already inside the cloned repo, pull latest
if [ -d ".git" ] && git remote get-url origin 2>/dev/null | grep -q "wickedyoda/public-setupfiles"; then
    echo "Already in public-setupfiles repo. Pulling latest changes..."
    git pull origin main
    exit_code=$?
    if [ $exit_code -eq 0 ]; then
        echo "Update complete!"
    else
        echo "Update failed with exit code $exit_code"
        exit $exit_code
    fi
    exit 0
fi

# Check if directory already exists
if [ -d "$LOCAL_DIR" ] && [ "$(ls -A "$LOCAL_DIR" 2>/dev/null)" ]; then
    echo "Existing directory found. Pulling latest changes..."
    if ! (cd "$LOCAL_DIR" && git pull origin main); then
        echo "Git pull failed, re-cloning..."
        rm -rf "$LOCAL_DIR"
        git clone "$REMOTE_REPO" "$LOCAL_DIR"
    fi
else
    echo "Cloning repository..."
    git clone "$REMOTE_REPO" "$LOCAL_DIR"
fi

cd "$LOCAL_DIR" || exit 1
chmod -R 755 .
echo "Done!"