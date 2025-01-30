#!/bin/bash

# Detect if the system is Debian/Ubuntu-based or OpenWRT
if command -v apt &> /dev/null; then
    PACKAGE_MANAGER="apt"
    UPDATE_CMD="sudo apt update -y"
    INSTALL_CMD="sudo apt install -y"
elif command -v opkg &> /dev/null; then
    PACKAGE_MANAGER="opkg"
    UPDATE_CMD="opkg update"
    INSTALL_CMD="opkg install"
else
    echo "Unsupported system. This script supports Debian/Ubuntu (apt) and OpenWRT (opkg)."
    exit 1
fi

# Update package lists
echo "Updating package lists using $PACKAGE_MANAGER..."
$UPDATE_CMD

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "Git is not installed. Installing git using $PACKAGE_MANAGER..."
    $INSTALL_CMD git
else
    echo "Git is already installed."
fi

# Specify the remote repository URL
remote_repo="https://github.com/wickedyoda/public-setupfiles.git"

# Specify the local file path
local_file="./public-setupfiles"

# Check if the local file path exists and is not empty
if [ -d "$local_file" ] && [ -n "$(ls -A $local_file 2>/dev/null)" ]; then
    echo "Existing directory detected. Deleting $local_file..."
    sudo rm -rf "$local_file"
fi

# Clone the remote repository to the local file path
echo "Cloning repository from $remote_repo to $local_file..."
git clone "$remote_repo" "$local_file"

# Make all files executable and set public ownership
echo "Setting permissions for $local_file..."
sudo chmod -R 777 "$local_file"

echo "Script execution completed successfully!"
