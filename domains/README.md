# domains

## Overview

This directory contains domain lists used for various purposes in the homelab, including Pi-hole blocking, VPN allowlists, and email filtering.

## Files

| File | Description |
|------|-------------|
| `bamboo_domains.txt` | Bambu Lab 3D printer domains |
| `bypass_sites.txt` | Sites to bypass VPN/proxy |
| `combined_list.txt` | Merged block + allow lists |
| `known_porn_domains.txt` | Adult content domains |
| `social_media.txt` | Social networking platforms |
| `streaming_domains_whitelist.txt` | Netflix, Hulu, HBO Max, etc. |
| `sweden_domains.txt` | Swedish-related domains |

## Usage

### Pi-hole Integration

```bash
# Add to Pi-hole
Group Management → Adlists → Add

# Use raw URL
https://raw.githubusercontent.com/wickedyoda/public-setupfiles/main/domains/social_media.txt
```

### Hosts File Blocking

```bash
# Append to /etc/hosts
127.0.0.1 blocked.domain.com
::1 blocked.domain.com
```

---

## Domains by Category

### Social Media

Facebook, Instagram, Twitter/X, TikTok, LinkedIn, Snapchat, Threads, Bluesky, Mastodon, Reddit, Discord, etc.

### Streaming Services

Netflix, Hulu, HBO Max, Disney+, Paramount+, Peacock, Amazon Prime Video, Disney+, etc.

### Adult Content

Pornhub, XVideos, XNXX, RedTube, YouPorn, Brazzers, Livejasmin, etc.

### Bambu Lab 3D

Domains for Bambu Lab printers:
- `bambulab.com`, `api.bambulab.com`
- `public-cdn.bambulab.cn`, `cloud.bambulab.com`
- `ota.bambulab.com`, `mqtt.bambulab.com`

---

## Related Directories

- `pihole/` — Pi-hole blocklists
- `unblocked_domains_for_VPN/` — VPN bypass domains
- `Email_domains_block_allow/` — Email filtering rules