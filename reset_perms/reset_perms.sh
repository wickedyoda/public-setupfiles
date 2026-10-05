#!/bin/bash

mounts=(
  "/mnt/backup-10t"
  "/mnt/backup-8t"
  "/mnt/hermes"
  "/mnt/primary-10t"
  "/mnt/primary-8t"
)

for dir in "${mounts[@]}"; do
  if ! mountpoint -q "$dir"; then
    echo "Error: $dir is not mounted. Mount it before running this script." >&2
    exit 1
  fi
done

echo "Setting chmod 777 on all mount contents..."
for dir in "${mounts[@]}"; do
  echo "Processing $dir..."
  if ! chmod -R 777 "$dir"; then
    echo "Error: failed to set permissions on $dir." >&2
    exit 1
  fi
done

echo "All permissions applied successfully."