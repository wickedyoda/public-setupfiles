# Kali Linux & Security Tools

Kali Linux setup and security tool installation scripts.

---

## Kali Tools Installation

### Location: `Kali_tools_install/`

| File | Purpose |
|------|---------|
| `setup_debian_kali_tools.sh` | Install Kali tools on Debian |
| `Kalitoolsinstall.sh` | Direct Kali tools install |

---

### `setup_debian_kali_tools.sh`

Install Kali security tools on a Debian system.

**Usage:**
```bash
sudo ./Kali_tools_install/setup_debian_kali_tools.sh
```

**Tool Categories:**

| Category | Tools |
|----------|-------|
| Identify | `kali-tools-identify` |
| Protect | `kali-tools-protect` |
| Detect | `kali-tools-detect` |
| Respond | `kali-tools-respond` |
| Recover | `kali-tools-recover` |

---

## Kali Purple

### Location: `kali-purple/`

Kali Linux Purple security platform setup.

### Files

| File | Purpose |
|------|---------|
| `install_kali_purple.sh` | Install Kali Purple tools |

---

### Installation

```bash
sudo ./kali-purple/install_kali_purple.sh
```

**What it installs:**
1. Kali Rolling sources
2. System updates
3. Kali Purple tools (`kali-tools-identify`, `kali-tools-protect`, etc.)
4. Purple theme (`kali-themes-purple`)
5. Legacy wallpapers

**Interactive prompts:**
- Kali tool categories (1-5 or 'all')
- Purple theme options (1-4)

---

## Kali Linux Conversion

### `debian-dist-upgrades/dist-upgrade.sh`

Option 4 allows converting Debian to Kali Linux.

```bash
# From the dist-upgrade script
4) Convert Debian to Parrot Linux

# For Kali, modify or use:
git clone https://gitlab.com/parrotsec/project/debian-conversion-script.git
cd debian-conversion-script
chmod +x ./install.sh
./install.sh
```

---

## Security Tool References

### Common Tools

| Category | Tools |
|----------|-------|
| Network Scanning | nmap, masscan |
| Web Apps | nikto, sqlmap, wfuzz |
| Wireless | aircrack-ng, reaver |
| Forensics | autopsy, volatility |
| Exploitation | metasploit, exploitdb |
| Password | john, hashcat, hydra |

---

## Usage Recommendations

### Virtual Environment

```bash
# Never run on production systems without testing
# Use VirtualBox or VMware for isolated testing
```

### Legal Compliance

```bash
# Only scan networks you own or have permission to test
# This software is for authorized security testing only
```