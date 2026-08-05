#!/bin/bash

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "Please run this script as root."
  exit 1
fi

# Backup the current sources.list
cp /etc/apt/sources.list /etc/apt/sources.list.bak
echo "Backup of sources.list created at /etc/apt/sources.list.bak"

# Add Kali rolling repository
echo "deb http://http.kali.org/kali kali-rolling main contrib non-free" | tee -a /etc/apt/sources.list
echo "Kali repository added."

# Import Kali's GPG key
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys ED444FF07D8D0BF6
echo "Kali GPG key imported."

# Update package lists
apt update

# Prompt user to select a Kali metapackage to install
echo "Select a Kali metapackage to install:"
echo "1) kali-linux-top10"
echo "2) kali-linux-default"
echo "3) kali-linux-all"
echo "4) kali-linux-wireless"
echo "5) kali-linux-web"
read -p "Enter the number corresponding to your choice: " choice

case $choice in
  1)
    apt install -y kali-linux-top10
    ;;
  2)
    apt install -y kali-linux-default
    ;;
  3)
    apt install -y kali-linux-all
    ;;
  4)
    apt install -y kali-linux-wireless
    ;;
  5)
    apt install -y kali-linux-web
    ;;
  *)
    echo "Invalid choice. Exiting."
    exit 1
    ;;
esac

echo "Installation of the selected Kali metapackage is complete."

# Reminder to remove Kali repositories after installation
echo "It's recommended to remove the Kali repository from /etc/apt/sources.list after installation to prevent potential system issues."