#!/bin/bash

# Check if the script is running on OpenWrt
if ! grep -q "OpenWrt" /etc/os-release; then
  echo "This script is designed to run on OpenWrt."
  exit 1
fi

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

echo "Enter the system location (e.g., Router Closet):"
read SYS_LOCATION
echo "Enter the system contact (e.g., admin@example.com):"
read SYS_CONTACT

# Update opkg and install SNMP
echo "Updating package list..."
opkg update

echo "Installing SNMP daemon..."
opkg install snmpd snmp-utils

# Stop SNMP service to configure it
echo "Stopping SNMP service..."
/etc/init.d/snmpd stop

# Backup the original SNMP configuration file
echo "Backing up the original configuration file..."
cp /etc/config/snmpd /etc/config/snmpd.bak

# Configure SNMPv3
echo "Configuring SNMPv3..."
cat <<EOT > /etc/config/snmpd
config agent
    option agentaddress 161
    option agentxsocket /var/agentx/master

config view
    option name all
    option type included
    option subtree .1

config access
    option groupname notConfigGroup
    option context ""
    option version v3
    option level authPriv
    option readview all
    option writeview none
    option notifyview none

config user
    option name $SNMP_USER
    option authproto MD5
    option authpass $SNMP_PASSWORD
    option privproto AES
    option privpass $SNMP_PASSWORD

config system
    option location "$SYS_LOCATION"
    option contact "$SYS_CONTACT"
EOT

# Restart and enable SNMP service
echo "Starting and enabling SNMP service..."
/etc/init.d/snmpd enable
/etc/init.d/snmpd start

# Verify SNMP configuration
echo "Verifying SNMP service..."
snmpwalk -v3 -u $SNMP_USER -a MD5 -A $SNMP_PASSWORD -x AES -X $SNMP_PASSWORD -l authPriv localhost

echo "SNMPv3 installation and configuration complete on OpenWrt."