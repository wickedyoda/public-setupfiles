# telegraf-setup-scripts

## Overview

Install and configure Telegraf metrics agent for system monitoring.

---

## Files

| Script | Description |
|--------|-------------|
| `install-client.sh` | Install Telegraf on Linux client |
| `update-telegraf-w-keys.sh` | Update with SSH key support |

---

## Installation

### Install Client

```bash
curl -s https://raw.githubusercontent.com/wickedyoda/public-setupfiles/main/telegraf-setup-scripts/install-client.sh | sudo bash
```

Or download:

```bash
curl -s https://raw.githubusercontent.com/wickedyoda/public-setupfiles/main/telegraf-setup-scripts/install-client.sh -o install-telegraf.sh
chmod +x install-telegraf.sh
sudo ./install-telegraf.sh
```

---

## What It Does

The script installs:
1. Telegraf service
2. Default configuration (often with InfluxDB input/output)
3. Optional: Secure secret storage

---

## Configuration

Telegraf configuration is typically at:
- `/etc/telegraf/telegraf.conf` (Linux)
- Custom configs via flags

Edit to add your InfluxDB or Prometheus endpoint.

---

## Uninstallation

```bash
# Remove package
sudo apt remove telegraf
sudo apt autoremove

# Remove config
sudo rm -rf /etc/telegraf
```

---

## Related

- [Monitoring Wiki](../Monitoring.md)
- `observium/` — Alternative monitoring agent