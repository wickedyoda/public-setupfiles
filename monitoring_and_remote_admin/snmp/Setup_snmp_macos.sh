#!/bin/bash

# Check if the script is running on macOS
if [[ "$(uname)" != "Darwin" ]]; then
  echo "This script is designed to run on macOS."
  exit 1
fi

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
  echo "Homebrew is not installed. Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install SNMP tools
echo "Installing SNMP tools via Homebrew..."
brew install net-snmp

# Prompt for user input
echo "Enter the SNMPv3 username (e.g., admin):"
read SNMP_USER
echo "Enter the SNMPv3 password:"
read -s SNMP_PASSWORD
echo "Re-enter the SNMPv3 password:"
read -s SNMP_PASSWORD_CONFIRM

# Verify password confirmation
if [ "$SNMP_PASSWORD" != "$SNMP_PASSWORD_CONFIRM" ]; then
  echo "Passwords do not match. Exiting."
  exit 1
fi

echo "Enter the system location (e.g., Office):"
read SYS_LOCATION
echo "Enter the system contact (e.g., admin@example.com):"
read SYS_CONTACT

# Configure SNMPv3
echo "Configuring SNMPv3..."
SNMP_CONF="/usr/local/etc/snmp/snmpd.conf"
sudo mkdir -p /usr/local/etc/snmp

cat <<EOT | sudo tee $SNMP_CONF
# SNMPv3 Configuration
createUser $SNMP_USER MD5 $SNMP_PASSWORD AES $SNMP_PASSWORD
rouser $SNMP_USER priv
agentAddress udp:161,udp6:[::1]:161
view all included .1 80
access notConfigGroup "" any noauth exact all none none
sysLocation "$SYS_LOCATION"
sysContact "$SYS_CONTACT"
EOT

# Restrict permissions on the configuration file
echo "Setting proper permissions for SNMP configuration..."
sudo chmod 600 $SNMP_CONF

# Start SNMP service
echo "Starting SNMP service..."
sudo launchctl load -w /Library/LaunchDaemons/org.net-snmp.snmpd.plist

# Verify SNMP configuration
echo "Verifying SNMP service..."
snmpwalk -v3 -u $SNMP_USER -a MD5 -A $SNMP_PASSWORD -x AES -X $SNMP_PASSWORD -l authPriv localhost

echo "SNMPv3 installation and configuration complete on macOS."
