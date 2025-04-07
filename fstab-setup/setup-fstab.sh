# Set path for credentials file
CREDENTIALS_FILE="$HOME/.smbcredentials"

# Prompt for username and password
echo "Creating SMB credentials file at $CREDENTIALS_FILE"
read -p "Enter your SMB username: " SMB_USER
read -s -p "Enter your SMB password: " SMB_PASS
echo

# Write to .smbcredentials securely
cat <<EOF > "$CREDENTIALS_FILE"
username=$SMB_USER
password=$SMB_PASS
EOF

chmod 600 "$CREDENTIALS_FILE"
echo "Created credentials file with 600 permissions."


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
cd /mnt
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
