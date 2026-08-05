!/bin/bash

# ----------------------------------------------------------------------
# | Add repos                                                          |
# ----------------------------------------------------------------------

# ----------------------------------------------------------------------
# | Update sources                                                     |
# ----------------------------------------------------------------------

sudo apt-get -y update
sudo apt-get -y dist-upgrade
sudo apt-get -y full-upgrade

# ----------------------------------------------------------------------
# | Install apps                                                       |
# ----------------------------------------------------------------------

sudo apt-get -y install
  wireshark\
  nmap \
  openvpn \
  etherape \
  remmina \
  monitorix \
  samba-common-bin \
  openssh-server \
  smbclient \
  cifs-utils \
  exfat-fuse \
  cups \
  software-properties-common \
  curl \
  unattended-upgrades \
  cron-apt \
  putty \
  gpart \
  deja-dup \
  git \
  curl \
  libgconf-2-4 \
  libappindicator1

# ----------------------------------------------------------------------
# | Install Discord                  |
# ----------------------------------------------------------------------

cd /home/traver/Downloads 
wget -O discord-0.0.1.deb https://discordapp.com/api/download?platform=linux&format=deb
sudo dpkg -i discord-0.0.1.deb


# ----------------------------------------------------------------------
# | creates folders for shares, Install fstab entries, maps mounts to nas|
# ----------------------------------------------------------------------

sudo cp /etc/fstab /etc/ftab.orig.backup

# cd ~/home/traver

sudo mkdir /home/traver/naspublic
sudo mkdir /home/traver/nasdownloadedmedia

sudo echo "//nas/public  /home/traver/naspublic  cifs  vers=2.0,username=admin,password=mypassword,file_mode=0777,dir_mode=0777 0 0
//nas/DownloadedMedia  /home/traver/nasdownloadedmedia  cifs vers=2.0,username=traver,password=mypassword,file_mode=0777,dir_mode=0777 0 0" >> /etc/fstab

sudo mount -a

# ----------------------------------------------------------------------
# | Update sources, Second time to complete installs.                  |
# ----------------------------------------------------------------------

sudo apt-get -y update
sudo apt-get -y dist-upgrade
sudo apt-get -y full-upgrade
sudo apt-get -y autoremove