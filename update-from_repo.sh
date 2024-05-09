#!/bin/bash

# Specify the remote repository URL
remote_repo="https://github.com/wickedyoda/public-setupfiles.git"

# Specify the local file path
local_file="./pubic-setupfiles"

# Check if the local file exists
if [ -f "$local_file" ]; then
    # Pull the latest updates from the remote repository
    git -C "$local_file" pull "$remote_repo"
else
    # Clone the remote repository to the local file path
    git clone "$remote_repo" "$local_file"
fi
