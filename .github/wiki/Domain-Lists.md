# Domain Lists

Domain blocklists, allowlists, and filtering rules used across the homelab.

---

## Domain List Overview

| Directory | Purpose |
|-----------|---------|
| `domains/` | General domain lists |
| `pihole/` | Pi-hole DNS blocklists |
| `unblocked_domains_for_VPN/` | VPN bypass domains |
| `Email_domains_block_allow/` | Email server policies |

---

## Pi-hole Lists

### Location: `pihole/`

| File | Description |
|------|-------------|
| `blocklist.txt` | 80,000+ ad/malware/social media domains |
| `whitelist.txt` | Streaming services (Netflix, Hulu, etc.) |
| `combined_list.txt` | Merged block + allow lists |

### Adding to Pi-hole

```bash
# In Pi-hole web UI
Group Management → Adlists → Add

# Use raw URLs:
https://raw.githubusercontent.com/wickedyoda/public-setupfiles/main/pihole/blocklist.txt
```

### Blocked Categories

- **Advertising:** Google Ads, DoubleClick, Taboola, Outbrain
- **Social Media:** Facebook, Instagram, Twitter, TikTok, LinkedIn
- **Adult Content:** Pornhub, XVideos, RedTube, YouPorn
- **Malware:** Known malicious domains
- **Gambling:** Betting and casino sites
- **Gaming:** Roblox, Discord, gaming trackers

---

## Unblocked VPN Domains

### Location: `unblocked_domains_for_VPN/`

**Purpose:** Domains that should bypass the VPN connection.

**File:** `unblocked_domains.txt`

**Includes:**
- Personal domains: `wickedyoda.com`, `tyates.one`, `twy4.us`
- Work domains: `traverates.com`, `sampyates.com`, `designsbymantha.com`
- Service domains: Tailscale, Home Assistant, etc.

---

## General Domain Lists

### Location: `domains/`

#### Social Media

**File:** `domains/social_media.txt`

Major platforms tracked:
- Facebook/Meta family
- Instagram
- Twitter/X
- TikTok
- LinkedIn
- Snapchat
- Threads
- Bluesky

---

#### Streaming Services

**File:** `domains/streaming_domains_whitelist.txt`

**Included:**
- Netflix (and CDN)
- Hulu
- HBO Max
- Disney+
- Paramount+
- Peacock
- Amazon Prime Video

---

#### Adult Content

**File:** `domains/known_porn_domains.txt`

Large blocklist of adult content domains.

---

#### Country Domains

**File:** `domains/sweden_domains.txt`

Domains associated with Sweden (for geo-filtering).

---

## Email Domain Filtering

### Location: `Email_domains_block_allow/`

| File | Purpose |
|------|---------|
| `blocked_domains.md` | Domains to reject in SMTP |
| `email_domain_allow_block_list.md` | Comprehensive rules |

### Use Cases

- **Postfix:** `header_checks`, `sender_access`
- **Exim:** `acl_smtp_dnsbl`
- **Exchange:** Transport Rules

---

## Bambu Lab Domains

### Location: `domains/bamboo_domains.txt`

Domains for Bambu Lab 3D printers:

```
bambulab.com
api.bambulab.com
public-cdn.bambulab.cn
cloud.bambulab.com
ota.bambulab.com
mqtt.bambulab.com
```

---

## Usage with Other Tools

### Pi-hole Adlist Format

```
https://raw.githubusercontent.com/wickedyoda/public-setupfiles/main/pihole/blocklist.txt
```

### Hosts File Format

```
127.0.0.1 domain.com
::1 domain.com
```

### BIND/DNS Server

Import as zone files or use as external lookup sources.