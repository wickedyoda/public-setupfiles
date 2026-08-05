#!/bin/bash

# SMB share credentials
NAS_USERNAME="your_username"
NAS_PASSWORD="your_password"
NAS_ADDRESS="nas"
NAS_SHARE="mymedia"

# Local folders to sync
LOCAL_FOLDERS=(
    "/path/to/your/folder1"
    "/path/to/your/folder2"
)

# Mount point for the SMB share
MOUNT_POINT="/Volumes/mymedia"

# Ensure the mount point exists
if [ ! -d "$MOUNT_POINT" ]; then
    mkdir -p "$MOUNT_POINT"
fi

# Mount the SMB share
echo "Mounting SMB share..."
mount -t smbfs "//$NAS_USERNAME:$NAS_PASSWORD@$NAS_ADDRESS/$NAS_SHARE" "$MOUNT_POINT"
if [ $? -ne 0 ]; then
    echo "Failed to mount SMB share. Please check your credentials and network connection."
    exit 1
fi

echo "SMB share mounted successfully at $MOUNT_POINT."

# Sync local folders to the SMB share
for LOCAL_FOLDER in "${LOCAL_FOLDERS[@]}"; do
    BASENAME=$(basename "$LOCAL_FOLDER")
    DESTINATION="$MOUNT_POINT/$BASENAME"
    
    echo "Syncing $LOCAL_FOLDER to $DESTINATION..."
    rsync -avh --progress "$LOCAL_FOLDER/" "$DESTINATION/"
    if [ $? -ne 0 ]; then
        echo "Failed to sync $LOCAL_FOLDER."
    else
        echo "Successfully synced $LOCAL_FOLDER."
    fi
done

# Unmount the SMB share
echo "Unmounting SMB share..."
umount "$MOUNT_POINT"
if [ $? -ne 0 ]; then
    echo "Failed to unmount SMB share. Please unmount it manually."
else
    echo "SMB share unmounted successfully."
fi

echo "Sync operation completed."