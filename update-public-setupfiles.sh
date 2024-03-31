
# Change to /home/traver
cd /home/traver

# Check distro and download updated public-setupfiles
if [ -x "$(command -v lsb_release)" ]; then
    distro=$(lsb_release -si)
else
    distro=$(cat /etc/os-release | grep -oP '(?<=^ID=).+' | tr -d '"')
fi

if [ "$distro" = "Ubuntu" ]; then
    # Pull file A
    wget https://raw.githubusercontent.com/wickedyoda/public-setupfiles/main/server_config/ubuntu/ubuntu-setup.sh
elif [ "$distro" = "Debian" ]; then
    # Pull file B
    wget https://raw.githubusercontent.com/wickedyoda/public-setupfiles/main/server_config/debian/debian-setup.sh
fi

# make updated files executable
cd /home/traver
chmod +x ./ubuntu-setup.sh
chmod +x ./debian-setup.sh

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

# make directory executable
chmod +x -R /home/traver/public-setupfiles