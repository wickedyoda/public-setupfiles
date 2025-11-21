# /bin/bash

# Backup of existing sources.list file
sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup

# Create variable from /etc/os-release file to get ID
ID=$(grep -oP '(?<=^ID=).+' /etc/os-release)
  
if [ "$ID" == "debian" ]; then
    echo "ID_LIKE is debian"
    echo "Updating sources.list file"
    echo "deb http://deb.debian.org/debian/ bookworm main contrib non-free" | sudo tee /etc/apt/sources.list
    echo "deb-src http://deb.debian.org/debian/ bookworm main contrib non-free" | sudo tee -a /etc/apt/sources.list
    echo "deb http://deb.debian.org/debian/ bookworm-updates main contrib non-free" | sudo tee -a /etc/apt/sources.list
    echo "deb-src http://deb.debian.org/debian/ bookworm-updates main contrib non-free" | sudo tee -a /etc/apt/sources.list
    echo "deb http://deb.debian.org/debian/ bookworm-backports main contrib non-free" | sudo tee -a /etc/apt/sources.list
    echo "deb-src http://deb.debian.org/debian/ bookworm-backports main contrib non-free" | sudo tee -a /etc/apt/sources.list
    echo "deb http://security.debian.org/debian-security/ bookworm-security main contrib non-free" | sudo tee -a /etc/apt/sources.list
    echo "deb-src http://security.debian.org/debian-security/ bookworm-security main contrib non-free" | sudo tee -a /etc/apt/sources.list
fi

if [ "$ID" == "ubuntu" ]; then
    echo "ID_LIKE is ubuntu"
    echo "Updating sources.list file"
    echo "deb http://archive.ubuntu.com/ubuntu/ Minotaur restricted universe multiverse" | sudo tee /etc/apt/sources.list
    echo "deb http://archive.ubuntu.com/ubuntu/ Minotaur main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
    echo "deb http://archive.ubuntu.com/ubuntu/ Minotaur main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
    echo "deb http://security.ubuntu.com/ubuntu Minotaur main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
fi

# update repositories
sudo apt update

# Full upgrade of system
sudo apt full-upgrade -y && sudo apt dist-upgrade -y

# Clean up system
sudo apt autoremove -y
sudo apt clean -y
sudo apt autopurge -y

echo "System update and cleanup complete!"

