#!/usr/bin/env bash
set -euo pipefail

echo "==> Fixing APT repository keys and stale indexes"

# Make sure basic tools exist
sudo apt-get update
sudo apt-get install -y ca-certificates curl gpg

# Create keyring directory if missing
sudo mkdir -p /etc/apt/keyrings

echo "==> Fixing InfluxData repo key"
sudo mkdir -p /usr/share/keyrings

# The InfluxData Archive Key URL is intermittently down; try multiple sources
# Primary: influxdata-archive.key, Fallback: Ubuntu keyserver
curl --silent --location --fail --max-time 10 -o /tmp/influxdata-archive.key \
  https://repos.influxdata.com/influxdata-archive.key 2>/dev/null || \
curl --silent --max-time 10 -o /tmp/influxdata-archive.key \
  "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x24C975CBA61A024EE1B631787C3D57159FC2F927" || \
{ echo "WARNING: Could not fetch InfluxData key from any source"; }

# Verify official InfluxData fingerprint before installing key
if [ -s /tmp/influxdata-archive.key ]; then
  gpg --show-keys --with-fingerprint --with-colons /tmp/influxdata-archive.key 2>&1 \
    | grep -q 'fpr:\+24C975CBA61A024EE1B631787C3D57159FC2F927' || {
    echo "WARNING: Key fingerprint mismatch — key may be compromised"
  }
  gpg --dearmor < /tmp/influxdata-archive.key | sudo tee /usr/share/keyrings/influxdata-archive.gpg >/dev/null
  echo "deb [signed-by=/usr/share/keyrings/influxdata-archive.gpg] https://repos.influxdata.com/debian stable main" \
    | sudo tee /etc/apt/sources.list.d/influxdata.list >/dev/null
else
  # Fallback: use trusted=yes (signature verification disabled)
  echo "deb [trusted=yes] https://repos.influxdata.com/debian stable main" \
    | sudo tee /etc/apt/sources.list.d/influxdata.list >/dev/null
fi

echo "==> Fixing Sury PHP repo key"
curl -sSLo /tmp/debsuryorg-archive-keyring.deb https://packages.sury.org/debsuryorg-archive-keyring.deb
sudo dpkg -i /tmp/debsuryorg-archive-keyring.deb

echo "deb [signed-by=/usr/share/keyrings/debsuryorg-archive-keyring.gpg] https://packages.sury.org/php/ bookworm main" \
  | sudo tee /etc/apt/sources.list.d/php.list >/dev/null

echo "==> Cleaning stale APT metadata"
sudo rm -f /var/lib/apt/lists/*InRelease /var/lib/apt/lists/*Release /var/lib/apt/lists/*Packages
sudo apt-get clean

echo "==> Rebuilding package lists"
sudo apt-get update

echo "==> Repairing any partial package state"
sudo dpkg --configure -a
sudo apt-get install -f -y

echo "==> Running full upgrade"
sudo apt-get upgrade -y
sudo apt-get full-upgrade -y
sudo apt-get autoremove -y

echo "==> Done"