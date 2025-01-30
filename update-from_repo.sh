#!/bin/bash

# Ensure script is run as root or with sudo
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root. Use sudo."
   exit 1
fi

# Detect if the system is Debian/Ubuntu-based
if ! command -v apt &> /dev/null; then
    echo "This script only supports Debian-based systems (Ubuntu, Debian, etc.)."
    exit 1
fi

# Update package lists
echo "Updating package lists..."
apt update -y

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "Git is not installed. Installing Git..."
    apt install -y git
else
    echo "Git is already installed."
fi

# Specify the remote repository URL
REMOTE_REPO="https://github.com/wickedyoda/public-setupfiles.git"

# Specify the local directory for the repository
LOCAL_DIR="./public-setupfiles"

# Check if the local directory exists and is not empty
if [ -d "$LOCAL_DIR" ] && [ -n "$(ls -A $LOCAL_DIR 2>/dev/null)" ]; then
    echo "Existing directory detected. Deleting $LOCAL_DIR..."
    rm -rf "$LOCAL_DIR"
fi

# Clone the remote repository to the local directory
echo "Cloning repository from $REMOTE_REPO to $LOCAL_DIR..."
git clone "$REMOTE_REPO" "$LOCAL_DIR"

# Ensure all files have proper execution permissions
echo "Setting permissions for $LOCAL_DIR..."
chmod -R 777 "$LOCAL_DIR"

echo "Script execution completed successfully!"