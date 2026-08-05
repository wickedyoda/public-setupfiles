#!/bin/bash

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

echo "Enter the system location (e.g., Data Center):"
read SYS_LOCATION
echo "Enter the system contact (e.g., admin@example.com):"
read SYS_CONTACT

# Update the system
echo "Updating system packages..."
apt update -y && apt upgrade -y

# Install SNMP and related packages
echo "Installing SNMP and dependencies..."
apt install -y snmpd snmp libsnmp-dev

# Stop SNMP service to configure it
echo "Stopping SNMP service..."
systemctl stop snmpd

# Backup the original SNMP configuration file
echo "Backing up the original configuration file..."
cp /etc/snmp/snmpd.conf /etc/snmp/snmpd.conf.bak

# Configure SNMPv3
echo "Configuring SNMPv3..."
cat <<EOT > /etc/snmp/snmpd.conf
# SNMPv3 Configuration
createUser $SNMP_USER MD5 $SNMP_PASSWORD AES $SNMP_PASSWORD
rouser $SNMP_USER priv
agentAddress udp:161,udp6:[::1]:161
view all included .1 80
access notConfigGroup "" any noauth exact all none none
sysLocation "$SYS_LOCATION"
sysContact "$SYS_CONTACT"
EOT

# Restrict access to the configuration file
echo "Restricting access to the configuration file..."
chmod 600 /etc/snmp/snmpd.conf

# Start and enable SNMP service
echo "Starting and enabling SNMP service..."
systemctl enable snmpd
systemctl start snmpd

# Verify SNMP configuration
echo "Verifying SNMP service..."
snmpstatus -v3 -u $SNMP_USER -a MD5 -A $SNMP_PASSWORD -x AES -X $SNMP_PASSWORD -l authPriv localhost

echo "SNMPv3 installation and configuration complete."