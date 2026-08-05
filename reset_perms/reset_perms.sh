#!/bin/bash

# Define mount points and devices
declare -A mounts=(
  ["/mnt/public"]="/dev/sdc1"
  ["/mnt/public-bk"]="/dev/sde1"
  ["/mnt/public2"]="/dev/sdd1"
  ["/mnt/public2-bk"]="/dev/sdb1"
)

# Ensure mount folders exist
for dir in "${!mounts[@]}"; do
  echo "Creating $dir if needed..."
  mkdir -p "$dir"
done

# Mount each device to its folder
for dir in "${!mounts[@]}"; do
  device="${mounts[$dir]}"
  echo "Mounting $device to $dir..."
  mount "$device" "$dir"
done

# Bind mount for timeshift folders
echo "Creating timeshift bind mounts..."
mkdir -p /mnt/timeshift /mnt/timeshift1
mount --bind /mnt/public2 /mnt/timeshift
mount --bind /mnt/public2-bk /mnt/timeshift1

# Apply root ownership and full permissions
echo "Setting root:root ownership and chmod 777..."
for path in /mnt/public /mnt/public-bk /mnt/public2 /mnt/public2-bk /mnt/timeshift /mnt/timeshift1; do
  echo "Processing $path..."
  chown -R root:root "$path"
  chmod -R 777 "$path"
done

echo "All mounts and permissions applied successfully."