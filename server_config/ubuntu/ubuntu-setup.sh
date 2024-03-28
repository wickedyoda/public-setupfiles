#!/bin/bash

# initial install
apt-get update -y

# installing git
sudo apt install git -y

# installing cockpit
sudo apt install cockpit -y

# Check if /home/traver/public-setupfiles exists
if [ -d "/home/traver/public-setupfiles" ]; then
    # Change directory to /home/traver/public-setupfiles
    cd /home/traver/public-setupfiles
    
    # Stash any local changes
    git stash
    
    # Pull the latest changes from the remote repository
    git pull
else
    # mkdir for git repo
    sudo mkdir -p /home/traver/public-setupfiles
    cd /home/traver/public-setupfiles
    git init
    git remote add origin https://github.com/wickedyoda/public-setupfiles
    git pull origin main
    git checkout main

fi

# Change permissions
sudo chmod +x -R /home/traver/public-setupfiles

# Run full updates first time
sudo /home/traver/public-setupfiles/updates/updates.sh

# Serer apps setup
sudo apt-get -y install cockpit samba-common-bin openssh-server smbclient cifs-utils exfat-fuse curl unattended-upgrades cron-apt git curl

