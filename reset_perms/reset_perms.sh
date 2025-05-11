#!/bin/bash

# Define mount points and devices
declare -A mounts=(
  ["/mnt/public"]="/dev/sdc1"
  ["/mnt/public-bk"]="/dev/sde1"
  ["/mnt/public2"]="/dev/sdd1"
  ["/mnt/public2-bk"]="/dev/sdb1"
)

# Create directories if missing
for dir in "${!mounts[@]}"; do
  echo "Creating $dir if it doesn't exist..."
  sudo mkdir -p "$dir"
done

# Mount main devices
for dir in "${!mounts[@]}"; do
  device="${mounts[$dir]}"
  echo "Mounting $device to $dir..."
  sudo mount "$device" "$dir"
done

# Bind mounts for timeshift folders
echo "Creating timeshift bind mounts..."
sudo mkdir -p /mnt/timeshift /mnt/timeshift1
sudo mount --bind /mnt/public2 /mnt/timeshift
sudo mount --bind /mnt/public2-bk /mnt/timeshift1

# Fix ownership and permissions
echo "Resetting permissions..."
for path in /mnt/public /mnt/public-bk /mnt/public2 /mnt/public2-bk /mnt/timeshift /mnt/timeshift1; do
  echo "Applying permissions to $path..."
  sudo chown -R traver:traver "$path"
  sudo chmod -R 777 "$path" 
done

echo "All mounts complete and permissions fixed."