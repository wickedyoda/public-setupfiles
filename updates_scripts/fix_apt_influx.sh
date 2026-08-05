#!/usr/bin/env bash
set -euo pipefail

echo "==> Fixing APT repository keys and stale indexes on Debian Bookworm"

# Make sure basic tools exist
sudo apt-get update
sudo apt-get install -y ca-certificates curl gpg

# Create keyring directory if missing
sudo mkdir -p /etc/apt/keyrings

echo "==> Fixing InfluxData repo key"
curl --silent --location -o /tmp/influxdata-archive.key https://repos.influxdata.com/influxdata-archive.key

# Verify official InfluxData fingerprint before installing key
gpg --show-keys --with-fingerprint --with-colons /tmp/influxdata-archive.key 2>&1 \
  | grep -q '^fpr:\+24C975CBA61A024EE1B631787C3D57159FC2F927:$'

gpg --dearmor < /tmp/influxdata-archive.key | sudo tee /etc/apt/keyrings/influxdata-archive.gpg >/dev/null

echo "deb [signed-by=/etc/apt/keyrings/influxdata-archive.gpg] https://repos.influxdata.com/debian stable main" \
  | sudo tee /etc/apt/sources.list.d/influxdata.list >/dev/null

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