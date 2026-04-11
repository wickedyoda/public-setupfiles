#!/bin/bash

# Define variables
CREDENTIALS_FILE="/root/.smbcredentials"
FSTAB_FILE="/etc/fstab"

# 1️⃣ Prompt for Username and Password
read -p "Enter NAS Username: " NAS_USER
read -s -p "Enter NAS Password: " NAS_PASS
echo ""  # Move to a new line after password entry

# 2️⃣ Install CIFS Utilities
echo "🔹 Installing CIFS utilities..."
sudo apt update && sudo apt install -y cifs-utils

# 3️⃣ Create Mount Points
echo "🔹 Creating mount points..."
sudo mkdir -p /mnt/naspublic /mnt/nasmedia /mnt/naspublic-share2

# 4️⃣ Securely Store Credentials
echo "🔹 Creating SMB credentials file..."
sudo bash -c "echo -e 'username=$NAS_USER\npassword=$NAS_PASS' > $CREDENTIALS_FILE"
sudo chmod 600 "$CREDENTIALS_FILE"

# 5️⃣ Update fstab Entries
echo "🔹 Updating /etc/fstab..."
FSTAB_ENTRIES="
//nas/Public /mnt/naspublic cifs credentials=$CREDENTIALS_FILE,vers=2.0,file_mode=0777,dir_mode=0777,_netdev,x-systemd.automount,nofail 0 0
//nas/media /mnt/nasmedia cifs credentials=$CREDENTIALS_FILE,vers=2.0,file_mode=0777,dir_mode=0777,_netdev,x-systemd.automount,nofail 0 0
//nas/public2 /mnt/naspublic-share2 cifs credentials=$CREDENTIALS_FILE,vers=2.0,file_mode=0777,dir_mode=0777,_netdev,x-systemd.automount,nofail 0 0
"

if ! grep -q "//nas/Public" "$FSTAB_FILE"; then
    echo "$FSTAB_ENTRIES" | sudo tee -a "$FSTAB_FILE" > /dev/null
    echo "✅ fstab updated."
else
    echo "✅ fstab entries already exist."
fi

# 6️⃣ Apply the Mounts
echo "🔹 Mounting all fstab entries..."
sudo mount -a

# Verify if the shares are mounted
echo "🔹 Checking mounted shares..."
df -h | grep /mnt/nas

echo "✅ Setup complete!"