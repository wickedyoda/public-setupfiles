#!/bin/bash

echo "Disabling creation of .DS_Store on network drives..."

# Disable writing .DS_Store files on network volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool TRUE
sudo defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool TRUE

echo "Deleting existing .DS_Store files in home directory..."
sudo find ~ -name ".DS_Store" -delete

echo "Done. A reboot is required for changes to take effect."