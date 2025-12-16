# Debian Upgrade & Conversion Script

A **safe, interactive Debian system upgrade utility** designed for real-world administration.  
Supports standard upgrades, full upgrades, controlled distro upgrades (Debian 12 / 13), and optional Parrot Linux conversion — with logging and guardrails.

---

## 📌 Features

- ✔ Verifies the system is **Debian-based** before running
- ✔ Detects and displays current **Debian version & codename**
- ✔ Interactive menu-driven workflow
- ✔ Accepts **yes / no / y / n** for confirmations
- ✔ Preserves existing configuration files during upgrades
- ✔ Logs **all actions and output** to `./log.txt`
- ✔ Safe Debian **12 (Bookworm)** upgrade path
- ✔ Double-confirmation for **Debian 13 (Trixie – testing)**
- ✔ Comments out existing `sources.list` entries (never deletes)
- ✔ Optional **Parrot Linux conversion**
- ✔ Designed to be safe over SSH

---

## 📂 Files

```
.
├── debian-upgrade.sh
├── README.md
└── log.txt   (created at runtime)
```

---

## 🚀 Usage

### 1️⃣ Make executable
```bash
chmod +x debian-upgrade.sh
```

### 2️⃣ Run as root
```bash
sudo ./debian-upgrade.sh
```

All output is logged to:
```text
./log.txt
```

---

## 🧭 Menu Options

### Option 1 — apt upgrade
Performs a safe system update:
```bash
apt update
apt upgrade -y
apt autoremove -y
```

---

### Option 2 — apt full-upgrade
Handles dependency changes and removals:
```bash
apt update
apt upgrade -y
apt full-upgrade -y
apt autoremove -y
```

---

### Option 3 — Debian Distro Upgrade
Upgrade between major Debian releases.

**Targets:**
- Debian 12 (Bookworm – Stable)
- Debian 13 (Trixie – Testing) ⚠️ requires double confirmation

**Behavior:**
- Backs up `/etc/apt/sources.list`
- Comments out all existing repo entries
- Appends new release repositories
- Keeps existing config files
- Cleans obsolete packages

---

### Option 4 — Convert to Parrot Linux
Converts a Debian system into **Parrot OS** using the official conversion script.

```bash
git clone https://gitlab.com/parrotsec/project/debian-conversion-script.git
cd debian-conversion-script
chmod +x install.sh
./install.sh
```

⚠️ This is a one-way conversion.

---

## 🔒 Safety Measures

- Refuses to run on non-Debian systems
- Full execution logging
- Explicit confirmations for risky operations
- Non-interactive apt with preserved configs:
  - `--force-confold`
  - `--force-confdef`
- Debian 13 requires double confirmation

---

## 📝 Logs

All stdout and stderr are written to:
```
./log.txt
```

---

## ⚠️ Notes & Recommendations

- Always backup important data before distro upgrades
- For remote systems, consider running inside `tmux` or `screen`
- Debian 13 (Trixie) is testing — expect breakage
- Reboot may be required after kernel upgrades

---

## 📜 License

Use, modify, and distribute freely.  
No warranty — you run it, you own it.
