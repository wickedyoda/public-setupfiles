#!/bin/bash

set -e

# === CONFIGURATION ===
TOKEN_FILE="/run/secrets/${HOSTNAME}"
if [[ -r "$TOKEN_FILE" ]]; then
  TOKEN="$(sudo cat "$TOKEN_FILE")"
else
  echo "[!] Docker secret $TOKEN_FILE not found or unreadable." >&2
  read -rsp "Enter InfluxDB token: " TOKEN
  echo
  if [[ -z "$TOKEN" ]]; then
    echo "[✗] No token provided. Exiting." >&2
    exit 1
  fi
fi
BUCKET="Home_Network"
ORG="Home Network"
URL="http://docker2:8086"
DOCKER_SOCKET="/var/run/docker.sock"
TELEGRAF_CONF="/etc/telegraf/telegraf.conf"
BACKUP_PATH="/etc/telegraf/telegraf.conf.bak.$(date +%F-%H%M%S)"

echo "[+] Backing up current config to $BACKUP_PATH"
sudo cp "$TELEGRAF_CONF" "$BACKUP_PATH"

echo "[+] Updating InfluxDB output block..."

if grep -q '^\[\[outputs.influxdb_v2\]\]' "$TELEGRAF_CONF"; then
  echo "[+] Found existing outputs.influxdb_v2 block. Updating values..."
  sudo sed -i '/^\[\[outputs.influxdb_v2\]\]/,/^\[/ s|^\(  token = \).*|\1 "'"$TOKEN"'"|' "$TELEGRAF_CONF"
  sudo sed -i '/^\[\[outputs.influxdb_v2\]\]/,/^\[/ s|^\(  urls = \).*|\1 ["'"$URL"'"]|' "$TELEGRAF_CONF"
  sudo sed -i '/^\[\[outputs.influxdb_v2\]\]/,/^\[/ s|^\(  organization = \).*|\1 "'"$ORG"'"|' "$TELEGRAF_CONF"
  sudo sed -i '/^\[\[outputs.influxdb_v2\]\]/,/^\[/ s|^\(  bucket = \).*|\1 "'"$BUCKET"'"|' "$TELEGRAF_CONF"
else
  echo "[+] outputs.influxdb_v2 block not found. Appending to config..."
  cat <<EOF | sudo tee -a "$TELEGRAF_CONF" > /dev/null

[[outputs.influxdb_v2]]
  urls = ["$URL"]
  token = "$TOKEN"
  organization = "$ORG"
  bucket = "$BUCKET"
EOF
fi

echo "[+] Checking for Docker plugin..."
if ! grep -q '^\s*\[\[inputs.docker\]\]' "$TELEGRAF_CONF"; then
cat <<EOF | sudo tee -a "$TELEGRAF_CONF" > /dev/null

[[inputs.docker]]
  endpoint = "unix://$DOCKER_SOCKET"
  gather_services = false

EOF
  echo "[+] Docker plugin added."
else
  echo "[+] Docker plugin already present. Skipping."
fi

echo "[+] Validating config..."
if sudo telegraf --config "$TELEGRAF_CONF" --config-directory /etc/telegraf/telegraf.d --test > /dev/null; then
  echo "[✓] Config is valid."
else
  echo "[✗] Config test failed. Check output and fix issues." >&2
  exit 1
fi

echo "[+] Restarting Telegraf service..."
sudo systemctl restart telegraf

sleep 2
if systemctl is-active --quiet telegraf; then
  echo "[✓] Telegraf is now running."
else
  echo "[✗] Telegraf failed to start. Check logs with: journalctl -xeu telegraf.service" >&2
  exit 1
fi

echo "[✓] Setup complete on $(hostname)."
