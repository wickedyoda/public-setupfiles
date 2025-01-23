# Update package lists and install dependencies
sudo apt update
sudo apt-get install libffi-dev libssl-dev python3-dev python3-pip -y

# Script install docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Script: install_docker_compose.sh
# Description: Script to install Docker Compose and its dependencies on Linux

# Install Docker Compose using pip
sudo pip3 install docker-compose

# Download Docker Compose executable
DOCKER_COMPOSE_VERSION=2.20.3
sudo curl -L --fail https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION}/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose

# Make Docker Compose executable
sudo chmod +x /usr/local/bin/docker-compose

# Check if Docker Compose installation was successful
if [ $? -eq 0 ]; then
    echo "Docker Compose is installed and ready to use."
else
    echo "Failed to install Docker Compose."
fi