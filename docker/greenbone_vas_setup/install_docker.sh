#!/usr/bin/env bash
set -euo pipefail

# Remove previous conflicting packages
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do
  sudo apt remove "$pkg" -y
done

#updates, setup souces and install.
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update

#install docker
sudo apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y

# Add user to docker group
sudo usermod -aG docker "$USER"
echo "[*] Added $USER to docker group."
echo "[!] Log out and log back in for Docker group changes to take effect."

# create download dir:
export DOWNLOAD_DIR=$HOME/greenbone-community-container && mkdir -p $DOWNLOAD_DIR
