#!/bin/sh

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Use sudo or run as root."
    exit 1
fi

echo "Starting SNMPv2 configuration on OpenWRT..."

# Install SNMP if not installed
opkg update
opkg install snmpd

# Define SNMP configuration file location
SNMP_CONFIG="/etc/config/snmpd"

# Backup existing SNMP configuration
if [ -f "$SNMP_CONFIG" ]; then
    echo "Backing up existing SNMP configuration..."
    cp "$SNMP_CONFIG" "$SNMP_CONFIG.bak"
fi

# Create SNMPv2 configuration with public community
echo "Configuring SNMPv2 with public community..."

cat <<EOL > "$SNMP_CONFIG"
config system
    option enable '1'

config agent
    option agentaddress 'udp:161'

config com2sec
    option secname 'public'
    option source 'default'
    option community 'public'

config group
    option groupname 'publicGroup'
    option securitymodel 'v2c'
    option secname 'public'

config view
    option viewname 'all'
    option type 'included'
    option oid '.1'

config access
    option groupname 'publicGroup'
    option securitymodel 'v2c'
    option context 'none'
    option level 'noAuthNoPriv'
    option prefix 'exact'
    option read 'all'
    option write 'none'
    option notify 'none'
EOL

# Restart the SNMP service to apply changes
echo "Restarting SNMP service..."
/etc/init.d/snmpd restart

# Verify if SNMP is running
if pgrep snmpd > /dev/null; then
    echo "SNMP service is running."
else
    echo "Failed to start SNMP service."
    exit 1
fi

# Test SNMPv2 configuration
echo "Testing SNMPv2 configuration with snmpwalk..."
snmpwalk -v2c -c public localhost system

echo "SNMPv2 configuration on OpenWRT completed successfully!"