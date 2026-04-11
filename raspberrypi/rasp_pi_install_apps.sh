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
  libgconf-2-4 


# ----------------------------------------------------------------------
# | Install plugin for Netflix and video play on Pi                    |
# ----------------------------------------------------------------------

curl -fsSL https://pi.vpetkov.net -o ventz-media-pi
sh ventz-media-pi

# ----------------------------------------------------------------------
# | Complete updates and finalize                                      |
# ----------------------------------------------------------------------

sudo apt-get -y update
sudo apt-get -y dist-upgrade
sudo apt-get -y full-upgrade
sudo apt -y autoremove
sudo apt -y clean 
sudo apr -y purge