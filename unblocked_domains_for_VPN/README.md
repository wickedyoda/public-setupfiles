# unblocked_domains_for_VPN

## Overview

A list of domains that should bypass VPN connections for proper functionality.

---

## Files

| File | Description |
|------|-------------|
| `unblocked_domains.txt` | Domains allowed through VPN |

---

## Usage

### VPN Configuration

Add these domains to your VPN client's "split tunnel" or "bypass" settings:

```bash
# Example: OpenVPN route directive
route domain.com net_gateway
```

Or in WireGuard:

```ini
[Peer]
AllowedIPs = 10.0.0.0/8
Endpoint = twy4us.duckdns.org:51820
PersistentKeepalive = 25
```

---

## Domain Categories

### Personal Sites

- `wickedyoda.com` — Personal website
- `tyates.one` — Personal domain
- `twy4.us` — Short URL service

### Work Sites

- `traverates.com` — Work domain
- `sampyates.com` — Business domain
- `designsbymantha.com` — Design portfolio

### Internal/Cloud

- `homeassistant.local` — Home automation
- Cloud storage domains (personal)

---

## Related

- `pihole/` — DNS blocking for VPN-connected hosts
- `domains/` — General domain lists