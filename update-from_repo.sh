#!/bin/bash

# Specify the remote repository URL
remote_repo="https://github.com/wickedyoda/public-setupfiles.git"

# Specify the local file path
local_file="/home/traver/pubic-setupfiles"

# Check if the local file path exists and is not empty
if [ -d "$local_file" ] && [ -n "$(ls -A $local_file)" ]; then
    # Delete the existing directory
    rm -rf "$local_file"
fi

# Clone the remote repository to the local file path
git clone "$remote_repo" "$local_file"

cd /home/traver
chmod +x ./public-setupfiles/*.sh