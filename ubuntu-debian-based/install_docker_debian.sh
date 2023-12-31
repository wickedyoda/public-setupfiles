/#bash

#Make sure Cache is updated
apt update

# Bring system up to date (can be # out as not always required)
apt upgrade -y

#install certs app
apt install ca-certificates curl gnupg

#import keyrings
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

#Add docker repo to apt sources
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
   tee /etc/apt/sources.list.d/docker.list > /dev/null

#Pull cache sources including docker now.
apt update

#install docker
apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

#Add current user to docker admin group, takes affect after logout and back in
usermod -aG docker $USER
newgrp docker