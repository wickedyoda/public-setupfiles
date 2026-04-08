#!/bin/bash

# Make sure the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "❌ This script must be run as root. Try: sudo $0"
   exit 1
fi

echo "🔧 Updating Kali sources.list for rolling release..."
cat <<EOF > /etc/apt/sources.list
# See https://www.kali.org/docs/general-use/kali-linux-sources-list-repositories/
deb http://http.kali.org/kali kali-rolling main contrib non-free non-free-firmware
# Additional line for source packages
# deb-src http://http.kali.org/kali kali-rolling main contrib non-free non-free-firmware
EOF

echo "📦 Updating system packages..."
apt update && apt upgrade -y && apt autoremove -y

echo "🛡 Installing Kali Purple tools..."
apt install -y kali-tools-identify kali-tools-protect kali-tools-detect kali-tools-respond kali-tools-recover

echo "🎨 Installing Purple theme..."
apt install -y kali-themes-purple

echo "📂 Reinstalling Kali menu to apply changes..."
apt install --reinstall -y kali-menu

echo "🖼 Installing legacy wallpapers..."
apt install -y kali-wallpapers-legacy

echo "✅ Kali Purple setup complete!"