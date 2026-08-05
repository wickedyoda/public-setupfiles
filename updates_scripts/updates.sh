sudo ./fix_apt_influx.sh

sudo apt update
sudo apt upgrade -y
sudo apt full-upgrade -y
sudo apt autoremove -y
sudo apt clean -y
sudo apt purge -y
echo "System update and cleanup complete!"