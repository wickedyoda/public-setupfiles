for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done
# Remove docker.io, docker-doc, docker-compose, podman-docker, containerd, runc
sudo apt-get purge docker.io docker-doc docker-compose podman-docker containerd runc

# update repos
sudo apt-get update

# install dependencies
sudo apt-get install ca-certificates curl -y
sudo install -m 0755 -d /etc/apt/trusted.gpg.d
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/docker.gpg

# Add docker repo to apt/sources.list.d
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/trusted.gpg.d/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# run apt update
sudo apt-get update

# Install docker and docker-compose
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# adduser traver to docker
sudo adduser $USER docker

# echo done
echo "Install complete, please reboot"