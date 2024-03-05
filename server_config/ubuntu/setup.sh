/bash

# initial install
sudo apt-get update -y

# installing git
sudo apt install git -y

# mkdir for git repo
sudo mkdir /home/traver/public-setupfiles
cd /home/traver/public-setupfiles
git init
git remote add origin https://github.com/wickedyoda/public-setupfiles
git pull
git checkout main

# Change permissions
sudo chmod +x -R /home/traver/public-setupfiles

# Run full updates first time
sudo /home/traver/public-setupfiles/updates/updates.sh

# Serer apps setup
sudo apt-get -y install cockpit samba-common-bin openssh-server smbclient cifs-utils exfat-fuse curl unattended-upgrades cron-apt git curl
