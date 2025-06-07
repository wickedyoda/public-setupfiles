#!/bin/bash

# Exit on error
set -e

# Confirm OpenWrt OS
if ! grep -q "OpenWrt" /etc/os-release; then
  echo "❌ This script must be run on an OpenWrt device."
  exit 1
fi

echo "✔ OpenWrt detected: $(. /etc/os-release && echo $PRETTY_NAME)"

# Get SNMPv3 user info
read -p "Enter SNMPv3 username (e.g., admin): " SNMP_USER
read -s -p "Enter SNMPv3 password: " SNMP_PASSWORD
echo
read -s -p "Re-enter SNMPv3 password: " SNMP_PASSWORD_CONFIRM
echo

if [ "$SNMP_PASSWORD" != "$SNMP_PASSWORD_CONFIRM" ]; then
  echo "❌ Passwords do not match. Exiting."
  exit 1
fi

read -p "Enter SNMP system location (e.g., Router Closet): " SYS_LOCATION
read -p "Enter SNMP system contact (e.g., admin@example.com): " SYS_CONTACT

# Install SNMP
echo "📦 Installing snmpd and snmp-utils..."
opkg update
opkg install snmpd snmp-utils

# Stop service before config
echo "🛑 Stopping SNMP service..."
/etc/init.d/snmpd stop

# Backup config
cp /etc/config/snmpd /etc/config/snmpd.bak.$(date +%s)

# Write SNMP config
cat <<EOF > /etc/config/snmpd
config agent
	option agentaddress '161'
	option agentxsocket '/var/agentx/master'

config system
	option location '$SYS_LOCATION'
	option contact '$SYS_CONTACT'

config view
	option name 'all'
	option type 'included'
	option subtree '.1'

config access
	option groupname 'notConfigGroup'
	option context ''
	option version 'v3'
	option level 'authPriv'
	option readview 'all'
	option writeview 'all'
	option notifyview 'all'

config user
	option name '$SNMP_USER'
	option authproto 'MD5'
	option authpass '$SNMP_PASSWORD'
	option privproto 'AES'
	option privpass '$SNMP_PASSWORD'
EOF

# Enable and start SNMP
echo "🚀 Starting SNMP service..."
/etc/init.d/snmpd enable
/etc/init.d/snmpd start

# Configure firewall
echo "🔐 Adding firewall rule to allow SNMP on LAN (UDP/161)..."
uci add firewall rule
uci set firewall.@rule[-1].name='Allow-SNMP'
uci set firewall.@rule[-1].src='lan'
uci set firewall.@rule[-1].proto='udp'
uci set firewall.@rule[-1].dest_port='161'
uci set firewall.@rule[-1].target='ACCEPT'
uci commit firewall
/etc/init.d/firewall restart

# Test SNMP locally
echo "🧪 Running SNMPv3 test on localhost..."
snmpwalk -v3 -u "$SNMP_USER" -l authPriv -a MD5 -A "$SNMP_PASSWORD" -x AES -X "$SNMP_PASSWORD" localhost

echo "✅ SNMPv3 successfully configured on OpenWrt ${PRETTY_NAME}"