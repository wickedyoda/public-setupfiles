# WireGuard Client VPN Setup

Automated installer for WireGuard client tunnels on Debian/Ubuntu systems, connecting to the Flint4 router at `twy4us.duckdns.org`.

## Prerequisites

- A Debian/Ubuntu system (Debian 11+, Ubuntu 20.04+)
- Root/sudo access on the client machine
- A WireGuard configuration file (`.conf`) provided by the server administrator
- The WireGuard config must contain `[Interface]` and `[Peer]` sections

## Installation

1. Download the installer script:
   ```bash
   curl -sSL https://raw.githubusercontent.com/wickedyoda/public-setupfiles/main/"WG%20VPN%20setup"/install-wireguard-client.sh -o install-wireguard-client.sh
   chmod +x install-wireguard-client.sh
   ```

2. Run the installer:
   ```bash
   sudo ./install-wireguard-client.sh
   ```

3. When prompted, enter the path to your WireGuard configuration file (e.g., `/root/wg0.conf`, `/tmp/my-wg.conf`, etc.)

## What the Script Does

1. **Installs WireGuard**: `wireguard` and `wireguard-tools` packages
2. **Copies your config**: Places it at `/etc/wireguard/wgclient2.conf` with secure permissions (600)
3. **Creates a systemd service**: `wg-wgclient2.service` that:
   - Auto-starts on boot
   - Auto-restarts on failure
   - Starts after network is online
4. **Brings up the tunnel**: Immediately activates the WireGuard connection
5. **Verifies**: Confirms the interface is up and displays WireGuard handshake status

## Management Commands

```bash
# Check tunnel status
wg show wgclient2

# Bring tunnel down
sudo wg-quick down wgclient2

# Bring tunnel up
sudo wg-quick up wgclient2

# Check systemd service
sudo systemctl status wg-wgclient2

# Restart tunnel
sudo systemctl restart wg-wgclient2

# View logs
sudo journalctl -u wg-wgclient2 -f
```

## Configuration

The script hardcodes the following defaults:
- **Tunnel name**: `wgclient2` (interface name)
- **Peer host**: `twy4us.duckdns.org` (Flint4 DuckDNS hostname)
- **Config destination**: `/etc/wireguard/wgclient2.conf`

To change the tunnel name, edit the script before running it.

## Troubleshooting

- If the tunnel doesn't start, check: `sudo journalctl -u wg-wgclient2 -n 50`
- Verify config file permissions: `ls -la /etc/wireguard/wgclient2.conf` (must be 600)
- Test connectivity to the peer: `ping <tunnel-ip-from-config>`
- Check WireGuard errors: `sudo wg show wgclient2` (look for handshake errors)
