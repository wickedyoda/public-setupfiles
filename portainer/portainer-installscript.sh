#bash

#create the portainer volume:
docker volume create portainer_data

#Download and create portainer container, have to change default 8000 port on exposed side if you are running yacht on its default port. 
docker run -d -p 8099:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest