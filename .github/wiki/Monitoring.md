# Monitoring

Uptime Kuma automation, SNMP, Telegraf, and Observium monitoring tools.

---

## Uptime Updates Bot

### Location: `uptime-updates/`

A Python bot that syncs Docker container IDs with Uptime Kuma monitors when containers are recreated.

### Files

| File | Purpose |
|------|---------|
| `uptime-bot.py` | Main bot script |
| `config.yml` | Uptime Kuma API config |
| `container-monitor-map.yaml` | Container-to-monitor mappings |
| `requirements.txt` | Python dependencies |
| `setup-update_uptime-bot.sh` | Install script |
| `export-watchtower-bundle.sh` | Export Docker bundles |

### Configuration

#### `config.yml`

```yaml
uptime_kuma:
  url: "http://127.0.0.1:3001"
  api_key: "PUT_YOUR_API_KEY_HERE"

bot:
  dry_run: false
  request_timeout_seconds: 10
  poll_interval_seconds: 60
```

#### `container-monitor-map.yaml`

```yaml
mappings:
  - name: "media-server jellyfin"
    host_api: "tcp://10.0.84.21:2375"
    container_name: "jellyfin"
    uptime_monitor_id: 21
    expected_uptime_type: "docker"
```

### Installation

```bash
sudo bash setup-update_uptime-bot.sh
```

**Options:**
```bash
sudo bash setup-update_uptime-bot.sh --help

Options:
  --install-dir PATH     Install directory (default: /opt/uptime-updates)
  --service-name NAME    systemd unit name
  --user USER            User to run as
  --group GROUP          Group to run as
  --no-enable            Skip enabling on boot
  --no-start             Skip starting after install
  --overwrite-config     Replace existing config
  --overwrite-map        Replace existing map
  --dry-run              Print actions without executing
```

### Standalone Docker Deployment

#### `watchtower-export/`

Includes Docker Compose files for running without systemd:

- `docker-compose.watchtower-uptime-sync.yml` — Separate containers
- `docker-compose.watchtower-embedded.yml` — Embedded in watchtower

**Run:**
```bash
docker compose -f docker-compose.watchtower-uptime-sync.yml up -d
```

---

## SNMP Configuration

### Location: `snmp/`

SNMP setup scripts for various platforms.

#### Linux

**Files:**
| Script | Purpose |
|--------|---------|
| `setup_snmp.sh` | Standard Linux SNMPv3 setup |
| `setup_snmp_openwrt.sh` | OpenWrt SNMPv3 |
| `setup_snmp_openwrt_v2.sh` | OpenWrt SNMPv3 (alternative) |
| `setup_snmp_openwrt_publicv2.sh` | OpenWrt SNMPv2 (public) |

**Usage (Linux):**
```bash
sudo ./snmp/setup_snmp.sh
```

**Prompts:**
- SNMPv3 username and password
- System location
- System contact

**Features:**
- Creates `createUser` entry
- Sets up `rouser` with authPriv
- Configures firewall rules

#### macOS

**File:** `snmp/Setup_snmp_macos.sh`

```bash
brew install net-snmp
sudo ./snmp/Setup_snmp_macos.sh
```

---

## Telegraf Setup

### Location: `telegraf-setup-scripts/`

| File | Purpose |
|------|---------|
| `install-client.sh` | Install Telegraf client |
| `update-telegraf-w-keys.sh` | Update with SSH keys |

**Usage:**
```bash
curl -s https://raw.githubusercontent.com/wickedyoda/public-setupfiles/main/telegraf-setup-scripts/install-client.sh | sudo bash
```

---

## Observium Agent

### Location: `observium/`

Open-source network monitoring platform agent installer.

**Setup:**
```bash
sudo wget https://raw.githubusercontent.com/tkrause/Observium-Agent/master/agent.conf.sh
sudo wget https://raw.githubusercontent.com/tkrause/Observium-Agent/master/observium-agent-install.sh
sudo chmod +x agent.conf.sh observium-agent-install.sh
sudo ./observium-agent-install.sh
```

**Agent Config Options:**
```
$SYSCONTACT       # Email: "Name <email@example.com>"
$SYSLOCATION      # Physical location
$SNMP_COMMUNITY   # SNMP community string
$OBSERVIUM_HOST   # Observium server IP
$MODULES          # Optional: space-separated modules
$SVN_USER         # Enterprise license username
$SVN_PASS         # Enterprise license password
```

---

## Pi-hole

### Location: `pihole/`

Blocklists for Pi-hole DNS sinkhole.

| File | Type |
|------|------|
| `blocklist.txt` | Domains to block (adult, porn, gambling, etc.) |
| `whitelist.txt` | Netflix streaming domains |
| `combined_list.txt` | Merged block + allow lists |

**Usage:**
```bash
# In Pi-hole web UI
# Group Management → Adlists
# Add: https://raw.githubusercontent.com/wickedyoda/public-setupfiles/main/pihole/blocklist.txt
```

**Estimated domains blocked:**
- 80,000+ ad/malware domains
- 100+ social media domains
- 100+ streaming domains (whitelist)

---

## Domain Lists

### Location: `domains/`

| Directory | Description |
|-----------|-------------|
| `Email_domains_block_allow/` | Email server domain policies |
| `unblocked_domains_for_VPN/` | Domains allowed through VPN |

**Email Domain Files:**
- `blocked_domains.md` — Domains to block for email
- `email_domain_allow_block_list.md` — Allow/block rules

**Unblocked Domains:**
- Personal domains (wickedyoda.com, tyates.one)
- Work domains (traveryates.com, sampyates.com, etc.)