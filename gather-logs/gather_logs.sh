#!/bin/bash

DATE=$(date +%Y-%m-%d_%H-%M-%S)
HOST=$(hostname)

OUTDIR="/tmp/${DATE}-${HOST}"
ZIPFILE="/tmp/${DATE}-${HOST}.zip"

mkdir -p "$OUTDIR"

echo "Collecting logs into $OUTDIR..."



# Copy ALL log files recursively from /var/log, preserving directory structure
rsync -a /var/log/ "$OUTDIR/var_log/" 2>/dev/null

# Journal logs (Linux only)
if command -v journalctl >/dev/null 2>&1; then
	journalctl -b > "$OUTDIR/journal-current-boot.log" 2>/dev/null
	journalctl > "$OUTDIR/journal-all.log" 2>/dev/null
fi


# System info
uname -a > "$OUTDIR/uname.txt"
hostname > "$OUTDIR/hostnamectl.txt" 2>/dev/null
df -h > "$OUTDIR/disk-usage.txt"
if command -v free >/dev/null 2>&1; then
	free -h > "$OUTDIR/memory.txt"
else
	vm_stat > "$OUTDIR/memory.txt" 2>/dev/null
fi
if command -v ip >/dev/null 2>&1; then
	ip addr > "$OUTDIR/ip-addresses.txt"
else
	ifconfig > "$OUTDIR/ip-addresses.txt" 2>/dev/null
fi
if command -v systemctl >/dev/null 2>&1; then
	systemctl --failed > "$OUTDIR/failed-services.txt" 2>/dev/null
fi

# Create zip
zip -r "$ZIPFILE" "$OUTDIR" >/dev/null

echo ""
echo "Done."
echo "Created zip:"
echo "$ZIPFILE"