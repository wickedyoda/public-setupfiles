#!/bin/bash

DATE=$(date +%Y-%m-%d_%H-%M-%S)
HOST=$(hostname)

OUTDIR="/tmp/${DATE}-${HOST}"
ZIPFILE="/tmp/${DATE}-${HOST}.zip"

mkdir -p "$OUTDIR"

echo "Collecting logs into $OUTDIR..."

# Common logs
cp -a /var/log/syslog* "$OUTDIR/" 2>/dev/null
cp -a /var/log/auth.log* "$OUTDIR/" 2>/dev/null
cp -a /var/log/kern.log* "$OUTDIR/" 2>/dev/null
cp -a /var/log/daemon.log* "$OUTDIR/" 2>/dev/null
cp -a /var/log/dmesg* "$OUTDIR/" 2>/dev/null
cp -a /var/log/boot.log* "$OUTDIR/" 2>/dev/null
cp -a /var/log/dpkg.log* "$OUTDIR/" 2>/dev/null
cp -a /var/log/apt "$OUTDIR/" 2>/dev/null

# Journal logs
journalctl -b > "$OUTDIR/journal-current-boot.log" 2>/dev/null
journalctl > "$OUTDIR/journal-all.log" 2>/dev/null

# System info
uname -a > "$OUTDIR/uname.txt"
hostnamectl > "$OUTDIR/hostnamectl.txt" 2>/dev/null
df -h > "$OUTDIR/disk-usage.txt"
free -h > "$OUTDIR/memory.txt"
ip addr > "$OUTDIR/ip-addresses.txt"
systemctl --failed > "$OUTDIR/failed-services.txt" 2>/dev/null

# Create zip
zip -r "$ZIPFILE" "$OUTDIR" >/dev/null

echo ""
echo "Done."
echo "Created zip:"
echo "$ZIPFILE"