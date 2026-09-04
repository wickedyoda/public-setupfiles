# Network

VPN, firewall, domain lists, and network automation scripts.

---

## WireGuard VPN

### Location: `WG VPN setup/`

WireGuard client tunnel setup for connecting to the Flint4 router.

### Installation

```bash
# Download installer
curl -sSL https://raw.githubusercontent.com/wickedyoda/public-setupfiles/main/WG%20VPN%20setup/install-wireguard-client.sh -o install-wireguard-client.sh
chmod +x install-wireguard-client.sh

# Run
sudo ./install-wireguard-client.sh
```

### What the Script Does

1. **Installs WireGuard:** `wireguard` and `wireguard-tools` packages
2. **Copies config:** Places it at `/etc/wireguard/wgclient2.conf`
3. **Creates systemd service:** `wg-wgclient2.service`
4. **Activates tunnel:** Brings up the interface

### Management Commands

```bash
# Check tunnel status
wg show wgclient2

# Restart tunnel
sudo systemctl restart wg-wgclient2

# View logs
sudo journalctl -u wg-wgclient2 -f
```

### Configuration

Default settings:
- **Tunnel name:** `wgclient2`
- **Peer host:** `twy4us.duckdns.org` (Flint4 DuckDNS)
- **Config location:** `/etc/wireguard/wgclient2.conf`

**To customize:** Edit `install-wireguard-client.sh` before running.

---

## OpenVPN

### `ubuntu-based/ubuntu_install_apps.sh`

Includes OpenVPN client installation:

```bash
sudo apt update
sudo apt install -y openvpn
```

**Usage:**
```bash
sudo openvpn --config my-vpn.ovpn
```

---

## Pi-hole DNS

### Location: `pihole/`

DNS-based ad blocking and malware protection.

### Blocklists

| File | Description |
|------|-------------|
| `blocklist.txt` | 80,000+ ad/malware/social media domains |
| `whitelist.txt` | Netflix streaming domains |
| `combined_list.txt` | Merged block + allow lists |

### Integration

**Add to Pi-hole:**
```bash
# Via web UI
Group Management → Adlists → Add

# URL
https://raw.githubusercontent.com/wickedyoda/public-setupfiles/main/pihole/blocklist.txt
```

**Categories blocked:**
- Ad networks (Google Ads, DoubleClick, etc.)
- Social media trackers
- Adult content
- Gambling sites
- Malware domains

---

## Domain Lists

### `unblocked_domains_for_VPN/`

Domains that should bypass VPN (allow direct connection).

**File:** `unblocked_domains.txt`

**Contents:**
- Personal sites (wickedyoda.com, tyates.one)
- Work/business domains
- Local network domains

---

### `domains/`

Various domain lists for different purposes.

| File | Use Case |
|------|----------|
| `social_media.txt` | Social networking sites |
| `streaming_domains_whitelist.txt` | Netflix, Hulu, HBO Max, etc. |
| `known_porn_domains.txt` | Adult content |
| `bamboo_domains.txt` | Bambu Lab printer domains |

---

## Email Domain Filtering

### `Email_domains_block_allow/`

Domain policies for email servers.

| File | Purpose |
|------|---------|
| `blocked_domains.md` | Domains to reject at SMTP level |
| `email_domain_allow_block_list.md` | Comprehensive allow/block rules |

**Use with:**
- Postfix
- Exim
- Microsoft Exchange
- Any SMTP server supporting domain-based filtering

---

## Network Tools

### `docker_stuff/`

**File:** `docker_cleanup_updates.sh`

Combined Docker and system update script with network verification.

**Features:**
- System package updates
- Docker image/network pruning
- Container cleanup
- Build cache removal

### `docker/install_docker_debian.sh`

Docker installation with proper networking:
```bash
# After install, add user to docker group
sudo usermod -aG docker $USER
newgrp docker  # Or log out/in
```

---

## OpenWrt Router Scripts

### Location: `openwrt_scripts/`

| File | Purpose |
|------|---------|
| `openwrt_full-upgrade.sh` | Full OpenWrt firmware upgrade |
| `installing_ipref.sh` | IP configuration scripts |
| `openwrt_snmp_defaults.txt` | SNMP configuration templates |

**Usage:**
```bash
# SSH to router
ssh root@10.0.84.1

# Download and run
curl -sSL https://raw.githubusercontent.com/wickedyoda/public-setupfiles/main/openwrt_scripts/openwrt_full-upgrade.sh | sh
```