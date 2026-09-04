# snmp

## Overview

Scripts for setting up SNMP (Simple Network Management Protocol) monitoring on various platforms.

---

## Files

| Script | Platform | Version |
|--------|----------|---------|
| `setup_snmp.sh` | Linux | SNMPv3 |
| `setup_snmp_openwrt.sh` | OpenWrt | SNMPv3 |
| `setup_snmp_openwrt_v2.sh` | OpenWrt | SNMPv3 (alternative) |
| `setup_snmp_openwrt_publicv2.sh` | OpenWrt | SNMPv2 (public) |
| `Setup_snmp_macos.sh` | macOS | SNMPv3 |

---

## Linux SNMP Setup

### `setup_snmp.sh`

```bash
sudo ./snmp/setup_snmp.sh
```

**What it does:**
1. Prompts for SNMPv3 credentials
2. Installs snmpd and snmp packages
3. Configures SNMPv3 with authPriv (MD5+AES)
4. Sets up firewall rules
5. Starts and enables SNMP service

**Configures:**
- `/etc/snmp/snmpd.conf`
- Access restricted to local network

---

## OpenWrt SNMP Setup

### SNMPv3

```bash
ssh root@10.0.84.1
# Run on router
curl -sSL https://raw.githubusercontent.com/wickedyoda/public-setupfiles/main/snmp/setup_snmp_openwrt.sh | sh
```

**Interactively prompts for:**
- SNMPv3 username
- Password
- System location
- System contact

---

## macOS SNMP Setup

### `Setup_snmp_macos.sh`

```bash
# Install dependencies first
brew install net-snmp

# Then run script
sudo ./snmp/Setup_snmp_macos.sh
```

---

## SNMP Monitoring

### Test Connection

```bash
# From remote system
snmpwalk -v2c -c public 10.0.84.1 system
# Or SNMPv3
snmpwalk -v3 -u admin -l authPriv -a MD5 -A "password" \
  -x AES -X "password" 10.0.84.1 system
```

### Grafana Integration

Use any Prometheus/Grafana SNMP exporter with the configured community strings.

---

## Security

- Use SNMPv3 with authPriv whenever possible
- Restrict SNMP to management network
- Change default community strings
- Do not expose to the internet