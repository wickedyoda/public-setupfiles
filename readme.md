# Public Setup Files

This repository contains various setup scripts and configurations designed to automate system management and streamline deployment processes. The scripts are primarily designed for **Debian-based systems, Raspberry Pi, macOS, and Docker environments**.

## Repository Structure

### **Configuration Directories**
- **`cockpit/`** – Scripts for setting up and managing **Cockpit**, a web-based server management tool.
- **`compose_files/`** – **Docker Compose** files for orchestrating multi-container applications.
- **`portainer/`** – Setup files for **Portainer**, a web interface for Docker management.
- **`telegraf-setup-scripts/`** – Scripts for configuring **Telegraf**, an agent for collecting and reporting system metrics.

### **System Setup and Configuration**
- **`cron-job-setup-files/`** – Automation scripts for scheduled tasks using **cron**.
- **`debian-files/`** – Configuration files for **Debian-based** systems.
- **`fstab-setup/`** – Files for configuring **filesystem mounts**.
- **`server_config/`** – General **server configuration scripts**.
- **`ubuntu-debian-based/`** – Setup scripts tailored for **Ubuntu and Debian** systems.

### **Device-Specific Configurations**
- **`raspberrypi/`** – Setup scripts for **Raspberry Pi** devices.
- **`rasp2/`** – Additional Raspberry Pi configurations.
- **`mac-scripts/`** – Configuration and setup scripts for **macOS** systems.

### **Utility Scripts**
- **`batch_files/`** – **Windows batch scripts** for automation.
- **`copy-move-files/`** – Scripts to automate file operations.
- **`git_clone_setup/`** – Scripts for automating **Git repository cloning and setup**.
- **`reset_perms/`** – Scripts to **reset file/directory permissions**.
- **`updates_scripts/`** – Automated **system update scripts**.

### **Specialized Setup Scripts**
- **`greenbone_vas_setup/`** – Setup scripts for **Greenbone Vulnerability Assessment System**.
- **`omv/`** – Scripts for setting up **OpenMediaVault**, a NAS solution.

### **Root-Level Scripts and Files**
- **`Kalitoolsinstall.sh`** – Installs **Kali Linux security tools**.
- **`old-app-setup.sh`** – Legacy application setup script.
- **`update-from_repo.py`** & **`update-from_repo.sh`** – Scripts to **update systems from repositories**.
- **`.gitignore`** – Specifies ignored files for Git version control.
- **`LICENSE`** – **CC-BY-NC 4.0 License** (Attribution + NonCommercial).
- **`SECURITY.md`** – Security policies and guidelines.

---

## **Syncing This Repo Locally**
To clone and use this repository locally, run:
```bash
git init
git remote add origin https://github.com/wickedyoda/public-setupfiles
git fetch
git checkout main