# OpenWrt Router Setup

OpenWrt router configuration and management scripts.

---

## Scripts

### Location: `openwrt_scripts/`

| File | Purpose |
|------|---------|
| `openwrt_full-upgrade.sh` | Full firmware upgrade |
| `installing_ipref.sh` | IP configuration |
| `openwrt_snmp_defaults.txt` | SNMP config template |

---

## Full System Upgrade

### `openwrt_full-upgrade.sh`

Perform a complete OpenWrt upgrade.

**Usage:**
```bash
ssh root@10.0.84.1
curl -sSL https://raw.githubusercontent.com/wickedyoda/public-setupfiles/main/openwrt_scripts/openwrt_full-upgrade.sh | sh
```

**Process:**
1. Downloads latest firmware
2. Validates checksum
3. Backs up config
4. Performs sysupgrade

---

## IP Configuration

### `installing_ipref.sh`

Configure IP addresses and interfaces.

**Typical usage:**
```bash
# Access router via SSH
ssh root@192.168.1.1

# Run configuration script
./installing_ipref.sh
```

---

## SNMP on OpenWrt

### `openwrt_snmp_defaults.txt`

Default SNMP configuration for OpenWrt routers.

```bash
# Edit /etc/config/snmpd
config agent
    option agentaddress 'udp:161'

config view
    option name 'all'
    option type 'included'
    option oid '.1'

config group
    option groupname 'publicGroup'
    option securitymodel 'v2c'

config access
    option groupname 'publicGroup'
    option version 'v2c'
    option level 'noAuthNoPriv'
```

### Installation

```bash
# Install SNMP
opkg update
opkg install snmpd snmp-utils

# Configure
cat /etc/config/snmpd.d/openwrt-snmp_defaults.txt > /etc/config/snmpd

# Restart
/etc/init.d/snmpd restart
```

---

## OpenWrt Management Tips

### SSH Access

```bash
# Default credentials
root@openwrt

# Change password
passwd
```

### Package Management

```bash
# Install packages
opkg update
opkg install <package>

# List packages
opkg list-installed

# Remove packages
opkg remove <package>
```

### Configuration Backup

```bash
# Backup config
tar -czf /root/backup-$(date +%Y%m%d).tar.gz /etc/config/

# Restore
tar -xzf backup-20240101.tar.gz -C /
```

---

## Network Configuration

### Wireguard Client

For WireGuard client setup, see [WireGuard VPN](../WG%20VPN%20setup/readme.md).

### Port Forwarding

```bash
# Add port forward
uci add firewall redirect
uci set firewall.@redirect[-1].name='MyService'
uci set firewall.@redirect[-1].src='wan'
uci set firewall.@redirect[-1].src_dport='8080'
uci set firewall.@redirect[-1].dest='lan'
uci set firewall.@redirect[-1].dest_ip='192.168.1.100'
uci set firewall.@redirect[-1].dest_port='80'
uci commit firewall
/etc/init.d/firewall restart
```