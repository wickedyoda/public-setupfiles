#!/bin/bash

# run apt update to make sure the system is got latest repo files
sudo apt update -y

# Check if git is installed
if ! command -v git &> /dev/null; then
    # Install git
    sudo apt-get install git -y
fi

# Specify the remote repository URL
remote_repo="https://github.com/wickedyoda/public-setupfiles.git"

# Specify the local file path
local_file="./public-setupfiles"

# Check if the local file path exists and is not empty
if [ -d "$local_file" ] && [ -n "$(ls -A $local_file)" ]; then
    # Delete the existing directory
    sudo rm -rf "$local_file"
fi

# Clone the remote repository to the local file path
git clone "$remote_repo" "$local_file"

# Make all files executable and public ownership
sudo chmod 777 -R $local_file

