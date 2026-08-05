#!/bin/bash

LOGFILE="$HOME/dsstore_cleanup.log"

echo "=============================" | tee -a "$LOGFILE"
echo "Starting cleanup: $(date)" | tee -a "$LOGFILE"

# Supported Apple settings
echo "[1] Disable .DS_Store on network volumes..."
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

echo "[2] Disable .DS_Store on USB/removable volumes..."
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Global Git ignore
echo "[3] Adding .DS_Store to global git ignore..."
touch ~/.gitignore_global
grep -qxF ".DS_Store" ~/.gitignore_global || echo ".DS_Store" >> ~/.gitignore_global
git config --global core.excludesfile ~/.gitignore_global

# Delete existing files on all mounted volumes
echo "[4] Removing .DS_Store files from all local volumes..."
sudo find /Volumes /System/Volumes/Data "$HOME" \
-name ".DS_Store" -print -delete 2>/dev/null | tee -a "$LOGFILE"

echo "[5] Restarting Finder..."
killall Finder 2>/dev/null

echo "Finished: $(date)" | tee -a "$LOGFILE"
echo "============================="