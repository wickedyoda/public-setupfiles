# asking for password for fstab entry
read -p "Enter password: " PASSWORD

# installed needed package
apt update
apt-get -y install \
  samba-common-bin \
  smbclient \
  cifs-utils \
  exfat-fuse \
  curl \
  unattended-upgrades \
  cron-apt \
  git \
  curl

# Make directories
cd /media
mkdir nasmedia
mkdir naspublic
mkdir naspublic-share2

# Echo the command below into the file /etc/fstab
echo '# NAS Public Share
//nas/Public /mnt/naspublic cifs credentials=/root/.smbcredentials,vers=2.0,file_mode=0777,dir_mode=0777,_netdev,x-systemd.automount,nofail 0 0

# NAS Media Share
//nas/media /mnt/nasmedia cifs credentials=/root/.smbcredentials,vers=2.0,file_mode=0777,dir_mode=0777,_netdev,x-systemd.automount,nofail 0 0

# NAS Public2 Share
//nas/public2 /mnt/naspublic-share2 cifs credentials=/root/.smbcredentials,vers=2.0,file_mode=0777,dir_mode=0777,_netdev,x-systemd.automount,nofail 0 0' | sudo tee -a /etc/fstab

# Mount the file systems
mount -a
