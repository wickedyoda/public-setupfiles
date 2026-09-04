# pihole

## Overview

Pi-hole DNS blocking and domain list resources for ad-blocking and content filtering.

---

## Files

| File | Description |
|------|-------------|
| `blocklist.txt` | Comprehensive domain blocklist |
| `whitelist.txt` | Domains to allow through |
| `combined_list.txt` | Merged block + allow lists |

---

## Blocklist

### `blocklist.txt`

A comprehensive list of domains to block via DNS, including:
- Advertising networks
- Analytics trackers
- Social media domains
- Adult content sites
- Known malware domains

This is the primary source for Pi-hole's DNS blocking.

### `whitelist.txt`

Domains that should always resolve normally:
- Local services
- Required CDN domains
- Cloud services

### `combined_list.txt`

A ready-to-use combined list that can be imported directly.

---

## Usage with Pi-hole

### Adding Blocklist

1. Open Pi-hole Admin Console
2. **Group Management** → **Adlists**
3. Add these URLs:

```
https://raw.githubusercontent.com/wickedyoda/public-setupfiles/main/pihole/blocklist.txt
https://raw.githubusercontent.com/wickedyoda/public-setupfiles/main/pihole/whitelist.txt
```

4. Update gravity: `pihole -g`

---

## Customizing

Edit the files to add/remove domains:

```bash
# Edit blocklist
nano pihole/blocklist.txt

# Edit whitelist
nano pihole/whitelist.txt

# Regenerate combined list
cat pihole/blocklist.txt pihole/whitelist.txt > pihole/combined_list.txt
```

---

## Notes

- Whitelist domains should be a small, trusted list
- Too many whitelisted domains can create security issues
- Review lists periodically for accuracy
- Test new lists before deploying to production Pi-hole instances