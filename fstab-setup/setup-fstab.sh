# asking for password for fstab entry
read -s -p "Enter password: " PASSWORD

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

# Echo the command below into the file /etc/fstab
echo '//nas/public  /media/naspublic  cifs  vers=2.0,username=admin,password=$PASSWORD,file_mode=0777,dir_mode=0777,_netdev,auto 0 0
//nas/DownloadedMedia  /media/nasdownloadedmedia  cifs  vers=2.0,username=admin,password=$PASSWORD,file_mode=0777,dir_mode=0777,_netdev,auto 0 0' | sudo tee -a /etc/fstab

# Mount the file systems
mount -a
