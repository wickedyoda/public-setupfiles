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

sudo apt-get -y install \
  openvpn \
  samba-common-bin \
  openssh-server \
  smbclient \
  cifs-utils \
  exfat-fuse \
  exfat-utils \
  software-properties-common \
  python \
  curl \
  unattended-upgrades \
  cron-apt \
  deja-dup \
  git \
  curl \
  snapd \
  libgconf-2-4 \
  libappindicator1 \



# ----------------------------------------------------------------------
# | creates folders for shares, Install fstab entries, maps mounts to nas|
# ----------------------------------------------------------------------

sudo cp /etc/fstab /etc/ftab.orig.backup

# cd ~/home/traver

sudo mkdir /home/traver/naspublic
sudo mkdir /home/traver/nasdownloadedmedia

echo "//nas/public  /home/traver/naspublic  cifs  vers=2.0,username=admin,password=mypassword,file_mode=0777,dir_mode=0777 0 0
//nas/DownloadedMedia  /home/traver/nasdownloadedmedia  cifs vers=2.0,username=traver,password=mypassword,file_mode=0777,dir_mode=0777 0 0" >> /etc/fstab

sudo mount -a
