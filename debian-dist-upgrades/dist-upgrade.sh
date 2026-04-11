#!/bin/bash
set -o pipefail

LOGFILE="./log.txt"
exec > >(tee -a "$LOGFILE") 2>&1

echo "===== Debian Upgrade Script Started: $(date) ====="

# --------------------------------------------------
# Helper: yes/no prompt (accepts y|yes / n|no)
# --------------------------------------------------
ask_yes_no() {
  local prompt="$1"
  local reply
  while true; do
    read -rp "$prompt [y/n]: " reply
    case "${reply,,}" in
      y|yes) return 0 ;;
      n|no)  return 1 ;;
      *) echo "Please answer yes or no." ;;
    esac
  done
}

# --------------------------------------------------
# 1. Verify Debian-based OS
# --------------------------------------------------
if [[ ! -f /etc/os-release ]]; then
  echo "ERROR: Cannot detect OS."
  exit 1
fi

source /etc/os-release

if [[ "$ID_LIKE" != *"debian"* && "$ID" != "debian" ]]; then
  echo "ERROR: This system is not Debian-based."
  exit 1
fi

echo "Detected OS: $PRETTY_NAME"

# --------------------------------------------------
# 2. Identify version and prompt
# --------------------------------------------------
DEBIAN_VERSION="$VERSION_ID"
DEBIAN_CODENAME="$VERSION_CODENAME"

echo "Current Debian Version: $DEBIAN_VERSION ($DEBIAN_CODENAME)"

ask_yes_no "Continue?" || exit 0

# --------------------------------------------------
# 3. Upgrade Menu
# --------------------------------------------------
echo ""
echo "Select upgrade option:"
echo "1) apt upgrade"
echo "2) apt full-upgrade"
echo "3) Debian distro upgrade"
echo "4) Convert Debian to Parrot Linux"
read -rp "Choice [1-4]: " CHOICE

# Non-interactive + keep config files
export DEBIAN_FRONTEND=noninteractive
APT_OPTS=(
  "-o" "Dpkg::Options::=--force-confold"
  "-o" "Dpkg::Options::=--force-confdef"
)

# --------------------------------------------------
# Option 1: apt upgrade
# --------------------------------------------------
if [[ "$CHOICE" == "1" ]]; then
  apt update
  apt upgrade -y "${APT_OPTS[@]}"
  apt autoremove -y
  echo "apt upgrade completed."
  exit 0
fi

# --------------------------------------------------
# Option 2: apt full-upgrade
# --------------------------------------------------
if [[ "$CHOICE" == "2" ]]; then
  apt update
  apt upgrade -y "${APT_OPTS[@]}"
  apt full-upgrade -y "${APT_OPTS[@]}"
  apt autoremove -y
  echo "apt full-upgrade completed."
  exit 0
fi

# --------------------------------------------------
# Option 4: Parrot Linux Conversion
# --------------------------------------------------
if [[ "$CHOICE" == "4" ]]; then
  echo "WARNING: This will convert Debian into Parrot Linux."
  ask_yes_no "Are you sure you want to proceed?" || exit 1

  git clone https://gitlab.com/parrotsec/project/debian-conversion-script.git
  cd debian-conversion-script || exit 1
  chmod +x ./install.sh
  ./install.sh
  exit $?
fi

# --------------------------------------------------
# Option 3: Debian Distro Upgrade
# --------------------------------------------------
if [[ "$CHOICE" != "3" ]]; then
  echo "Invalid selection."
  exit 1
fi

echo ""
echo "Select Debian upgrade target:"
echo "1) Debian 12 (Bookworm - Stable)"
echo "2) Debian 13 (Trixie - Testing)"
read -rp "Choice [1-2]: " TARGET

# Backup sources.list
cp /etc/apt/sources.list /etc/apt/sources.list.bak.$(date +%F)

# Comment out existing entries (do not delete)
sed -i 's/^[^#]/#&/' /etc/apt/sources.list

# --------------------------------------------------
# Debian 12
# --------------------------------------------------
if [[ "$TARGET" == "1" ]]; then
  echo "Preparing upgrade to Debian 12 (Bookworm)"

cat <<EOF >> /etc/apt/sources.list

# Debian 12 Bookworm Repositories
deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware
deb http://deb.debian.org/debian bookworm-updates main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware
EOF

  apt update
  apt upgrade -y "${APT_OPTS[@]}"
  apt full-upgrade -y "${APT_OPTS[@]}"
  apt autoremove -y

  echo "Upgrade to Debian 12 completed."
  exit 0
fi

# --------------------------------------------------
# Debian 13 (Double Confirmation)
# --------------------------------------------------
if [[ "$TARGET" == "2" ]]; then
  echo "WARNING: Debian 13 (Trixie) is TESTING."

  ask_yes_no "Do you understand this is a testing release?" || exit 1
  ask_yes_no "Confirm upgrade to Debian 13?" || exit 1

cat <<EOF >> /etc/apt/sources.list

# Debian 13 Trixie Repositories
deb http://deb.debian.org/debian trixie main contrib non-free non-free-firmware
deb http://deb.debian.org/debian trixie-updates main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security trixie-security main contrib non-free non-free-firmware
EOF

  apt update
  apt upgrade -y "${APT_OPTS[@]}"
  apt full-upgrade -y "${APT_OPTS[@]}"
  apt autoremove -y
  apt clean
  apt purge -y '~c'

  echo "Upgrade to Debian 13 completed."
  exit 0
fi

echo "Unknown error occurred."
exit 1