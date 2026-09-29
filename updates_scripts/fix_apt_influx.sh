#!/usr/bin/env bash
# Repair APT repository keys, then upgrade.
#
# ORDER MATTERS: keys are repaired BEFORE the first `apt-get update`.
# A system with a broken repo makes `apt-get update` exit 100, which under
# `set -e` would abort this script before it could fix anything.
set -uo pipefail

echo "==> Detecting suite"
# shellcheck disable=SC1091
. /etc/os-release
SUITE="${VERSION_CODENAME:-bookworm}"
echo "    suite=$SUITE"

# --- Preflight: tools must exist, but we must NOT depend on apt working yet ---
echo "==> Checking required tools"
MISSING=""
for tool in curl gpg dpkg; do
  command -v "$tool" >/dev/null 2>&1 || MISSING="$MISSING $tool"
done
if [ -n "$MISSING" ]; then
  echo "    missing:$MISSING - attempting install (best effort)"
  # Tolerate failure: a broken repo list must not abort the repair.
  apt-get update >/dev/null 2>&1 || true
  apt-get install -y ca-certificates curl gnupg >/dev/null 2>&1 || true
fi
for tool in curl gpg dpkg; do
  command -v "$tool" >/dev/null 2>&1 || { echo "FATAL: $tool unavailable, cannot repair keys"; exit 1; }
done

sudo mkdir -p /etc/apt/keyrings /usr/share/keyrings

# --- InfluxData ---
echo "==> Repairing InfluxData repo key"
INFLUX_FPR_PRIMARY="24C975CBA61A024EE1B631787C3D57159FC2F927"
INFLUX_FPR_SUBKEY="AC10D7449F343ADCEFDDC2B6DA61C26A0585BD3B"
KEYRING="/usr/share/keyrings/influxdata-archive.gpg"

fetch_influx_key() {
  # Primary: vendor-hosted key. Fallback: keyserver by subkey fingerprint.
  curl --silent --location --fail --max-time 15 -o /tmp/influxdata-archive.key \
    https://repos.influxdata.com/influxdata-archive.key 2>/dev/null && return 0
  curl --silent --location --fail --max-time 15 -o /tmp/influxdata-archive.key \
    "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x${INFLUX_FPR_SUBKEY}" 2>/dev/null && return 0
  return 1
}

# verify_influx_key FILE -> 0 if the primary fingerprint is present
verify_influx_key() {
  gpg --show-keys --with-fingerprint --with-colons "$1" 2>/dev/null \
    | grep -q "fpr:::::::::${INFLUX_FPR_PRIMARY}:"
}

INSTALL_INFLUX=0
if fetch_influx_key && [ -s /tmp/influxdata-archive.key ]; then
  if verify_influx_key /tmp/influxdata-archive.key; then
    gpg --dearmor < /tmp/influxdata-archive.key | sudo tee "$KEYRING" >/dev/null
    INSTALL_INFLUX=1
    echo "    key fetched and fingerprint verified"
  else
    echo "    WARNING: fetched key fingerprint mismatch - refusing to install"
  fi
else
  echo "    WARNING: could not fetch InfluxData key from any source"
fi

# Reuse an existing keyring only if it actually contains the right key.
if [ "$INSTALL_INFLUX" -eq 0 ] && [ -s "$KEYRING" ]; then
  if gpg --show-keys --with-fingerprint --with-colons "$KEYRING" 2>/dev/null \
       | grep -q "fpr:::::::::${INFLUX_FPR_PRIMARY}:"; then
    echo "    reusing verified existing keyring"
  else
    echo "    existing keyring is STALE/WRONG - removing so it is refetched"
    sudo rm -f "$KEYRING"
  fi
fi

if [ -s "$KEYRING" ]; then
  echo "deb [signed-by=${KEYRING}] https://repos.influxdata.com/debian stable main" \
    | sudo tee /etc/apt/sources.list.d/influxdata.list >/dev/null
else
  # No trustworthy key available. Disable the repo rather than falling back to
  # [trusted=yes], which would silently accept unsigned packages.
  echo "    no verifiable InfluxData key - disabling repo (not using trusted=yes)"
  sudo rm -f /etc/apt/sources.list.d/influxdata.list
fi

# --- Sury (PHP) ---
echo "==> Repairing Sury PHP repo key"
if curl -sSLo /tmp/debsuryorg-archive-keyring.deb --max-time 20 \
     https://packages.sury.org/debsuryorg-archive-keyring.deb 2>/dev/null \
   && [ -s /tmp/debsuryorg-archive-keyring.deb ]; then
  sudo dpkg -i /tmp/debsuryorg-archive-keyring.deb >/dev/null 2>&1 || true
  # Match the running suite instead of hardcoding bookworm (trixie hosts exist).
  echo "deb [signed-by=/usr/share/keyrings/debsuryorg-archive-keyring.gpg] https://packages.sury.org/php/ ${SUITE} main" \
    | sudo tee /etc/apt/sources.list.d/php.list >/dev/null
  echo "    configured for suite=${SUITE}"
else
  echo "    WARNING: could not fetch Sury keyring - skipping PHP repo"
fi

# --- Now refresh with the repaired keys in place ---
echo "==> Cleaning stale APT metadata"
sudo rm -f /var/lib/apt/lists/*InRelease /var/lib/apt/lists/*Release /var/lib/apt/lists/*Packages
sudo apt-get clean

echo "==> Rebuilding package lists"
if ! sudo apt-get update; then
  echo "ERROR: apt-get update still failing after key repair:"
  sudo apt-get update 2>&1 | grep -E '^(Err|W:|E:)' | head -20
  exit 1
fi

echo "==> Repairing any partial package state"
sudo dpkg --configure -a
sudo apt-get install -f -y

echo "==> Running full upgrade"
sudo apt-get upgrade -y
sudo apt-get full-upgrade -y
sudo apt-get autoremove -y

echo "==> Done"
