# Troubleshooting

Common issues and solutions for the public-setupfiles repository.

---

## Update Issues

### Script Fails with "Permission denied"

```bash
# Make sure script is executable
chmod +x update-from_repo.sh

# Or run with bash directly
bash update-from_repo.sh
```

---

### "Repository not found" Error

Check internet connectivity and GitHub status:
```bash
ping github.com
curl -I https://github.com/wickedyoda/public-setupfiles
```

---

### Path Typo in Python Script

The Python script has a typo: `pubic-setupfiles` instead of `public-setupfiles`.

**Fix:** Use the shell script or correct the path in `update-from_repo.py`.

---

## Docker Issues

### "Cannot connect to Docker daemon"

```bash
# Check if Docker is running
sudo systemctl status docker

# Start Docker
sudo systemctl start docker
```

### "Permission denied" for Docker Commands

```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Log out and back in, or run:
newgrp docker
```

### "Image prune" Fails

```bash
# Check disk space
df -h

# Force prune if needed
docker image prune -af --force
```

---

## WireGuard Issues

### "no key exchange maps available"

```bash
# Check WireGuard interface
sudo wg show wgclient2

# Restart service
sudo systemctl restart wg-wgclient2

# Check logs
sudo journalctl -u wg-wgclient2 -n 50
```

### Tunnel Won't Start

1. Verify config file permissions: `ls -la /etc/wireguard/`
2. Check config syntax: `sudo wg-quick strip wgclient2`
3. Verify peer is reachable: `ping <peer-ip>`

---

## Pi-hole Issues

### Domains Not Blocking

```bash
# Check gravity update
pihole -g

# Verify domain is in list
pihole -q example.com
```

### DNS Resolution Slow

```bash
# Check upstream servers
pihole -c

# Restart DNS
sudo systemctl restart pihole-FTL
```

---

## Uptime Kuma Bot Issues

### Bot Not Updating Container IDs

1. Check Docker API access:
```bash
curl http://docker-host:2375/version
```

2. Verify mapping file:
```bash
cat /opt/uptime-updates/container-monitor-map.yaml
```

3. Check bot logs:
```bash
journalctl -u uptime-updates-bot -f
```

---

## SNMP Issues

### "Timeout: No Response from Server"

1. Verify SNMP daemon:
```bash
systemctl status snmpd
```

2. Check firewall:
```bash
firewall-cmd --list-all
# Or iptables -L
```

3. Test locally:
```bash
snmpwalk -v2c -c public localhost system
```

---

## Permission Problems

### "Must be run as root" Error

Many scripts require root privileges:
```bash
sudo ./script.sh
```

Or switch to root:
```bash
su -
# or
sudo -i
```

---

## fstab Issues

### Mount Failures

```bash
# Check if mount points exist
ls -la /mnt/

# Create missing directories
sudo mkdir -p /mnt/naspublic

# Test mount
sudo mount -a -v

# Check logs
journalctl -b | grep mount
```

---

## Network Troubleshooting

### DNS Issues

```bash
# Check DNS resolution
nslookup google.com
dig google.com

# Check DNS server
cat /etc/resolv.conf
```

### Network Interface Down

```bash
# Check interfaces
ip addr show

# Bring interface up
sudo ip link set eth0 up
```

---

## System Logging

### View Update Logs

```bash
# System update logs
tail -f /var/log/auto_updates.log

# System journal
journalctl -u cron -f
```

### Collect System Information

```bash
# Run diagnostic script
./collect_info.sh

# View output
cat info.txt
```

---

## Recovery Procedures

### Restore fstab from Backup

```bash
# Restore backup
sudo cp /etc/fstab.bak /etc/fstab

# Or from date-stamped backup
sudo cp /etc/fstab.bak.2024-01-01 /etc/fstab
```

### Reinstall Docker

```bash
# Purge Docker
sudo apt purge docker.io docker-doc docker-compose podman-docker containerd runc

# Remove data
sudo rm -rf /var/lib/docker

# Reinstall
sudo ./docker/install_docker_debian.sh
```

### Reset Pi-hole

```bash
# Reinstall
pihole -r

# Or complete reinstall
sudo apt install --reinstall pihole
```