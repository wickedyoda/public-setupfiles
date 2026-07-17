#!/bin/sh

# Ensure script is run as root
if [ "$(id -u)" -ne 0 ]; then
   echo "This script must be run as root. Please run with sudo or as root user."
   exit 1
fi

# Function to automatically handle Git installation based on the platform
install_git() {
    if command -v apt-get >/dev/null 2>&1; then
        echo "Debian-based system detected. Updating apt and installing git..."
        apt-get update && apt-get install -y git
    elif command -v opkg >/dev/null 2>&1; then
        echo "OpenWrt system detected. Updating opkg and installing git..."
        opkg update && opkg install git git-http
    else
        echo "Error: Supported package manager (apt or opkg) not found. Install Git manually."
        exit 1
    fi
}

# Verify Git is installed, attempt installation if missing
if ! command -v git >/dev/null 2>&1; then
    echo "Git is not installed. Attempting auto-installation..."
    install_git
    
    # Double check if installation succeeded
    if ! command -v git >/dev/null 2>&1; then
        echo "Error: Git installation failed. Please install Git manually."
        exit 1
    fi
fi

# Specify the remote repository URL
REMOTE_REPO="https://github.com/wickedyoda/public-setupfiles.git"

# Specify the local directory for the repository
LOCAL_DIR="./public-setupfiles"

# Check if the local directory exists and is not empty
if [ -d "$LOCAL_DIR" ] && [ "$(ls -A "$LOCAL_DIR" 2>/dev/null)" ]; then
    echo "Existing directory detected. Deleting $LOCAL_DIR..."
    rm -rf "$LOCAL_DIR"
fi

# Clone the remote repository to the local directory
echo "Cloning repository from $REMOTE_REPO to $LOCAL_DIR..."
git clone "$REMOTE_REPO" "$LOCAL_DIR"

# Ensure all files have proper execution permissions
echo "Setting permissions for $LOCAL_DIR..."
chmod -R 755 "$LOCAL_DIR"

echo "Script execution completed successfully!"