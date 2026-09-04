#!/bin/bash

# Script: setup_portainer.sh
# Description: Script to set up Portainer using Docker on Linux

# Variables
PORTAINER_PORT=8099
DOCKER_SOCK=/var/run/docker.sock

# Create the portainer volume
docker volume create portainer_data

# Download and create portainer container
docker run -d -p $PORTAINER_PORT:8000 -p 9443:9443 --name portainer --restart=always -v $DOCKER_SOCK:$DOCKER_SOCK -v portainer_data:/data portainer/portainer-ce:latest

# Check if the container started successfully
if [ $? -eq 0 ]; then
    echo "Portainer container is up and running."
else
    echo "Failed to start Portainer container."
fi