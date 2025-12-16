#!/bin/bash
set -o pipefail

LOGFILE="./log.txt"
exec > >(tee -a "$LOGFILE") 2>&1

echo "===== Debian Upgrade Script Started: $(date) ====="

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
DEBIAN_VERSION=$(grep -oP '(?<=VERSION_ID=").*(?=")' /etc/os-release)
DEBIAN_CODENAME=$(grep -oP '(?<=VERSION_CODENAME=).*' /etc/os-release)

echo "Current Debian Version: $DEBIAN_VERSION ($DEBIAN_CODENAME)"
read -rp "Continue? (yes/no): " CONFIRM
[[ "$CONFIRM" != "yes" ]] && exit 0

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

# Ensure non-interactive config handling
export DEBIAN_FRONTEND=noninteractive
APT_OPTS="-o Dpkg::Options::=--force-confold -o Dpkg::Options::=--force-confdef"

# --------------------------------------------------
# Option 3: Debian Distro Upgrade
# --------------------------------------------------
if [[ "$CHOICE" == "3" ]]; then
  echo ""
  echo "Select Debian upgrade target:"
  echo "1) Debian 12 (Bookworm - Stable)"
  echo "2) Debian 13 (Trixie - Testing)"
  read -rp "Choice [1-2]: " TARGET

  # Backup sources.list
  cp /etc/apt/sources.list /etc/apt/sources.list.bak.$(date +%F)

  # Comment out existing entries (do not delete)
  sed -i 's/^[^#]/#&/' /etc/apt/sources.list

  if [[ "$TARGET" == "1" ]]; then
    echo "Preparing upgrade to Debian 12 (Bookworm)"

    cat <<EOF >> /etc/apt/sources.list

# Debian 12 Bookworm Repositories
deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware
deb http://deb.debian.org/debian bookworm-updates main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware
EOF

  elif [[ "$TARGET" == "2" ]]; then
    echo "WARNING: Debian 13 (Trixie) is TESTING."

    read -rp "Type I UNDERSTAND to continue: " CONFIRM1
    read -rp "Type UPGRADE TO 13 to confirm: " CONFIRM2

    if [[ "$CONFIRM1" != "I UNDERSTAND" || "$CONFIRM2" != "UPGRADE TO 13" ]]; then
      echo "Upgrade to Debian 13 aborted."
      exit 1
    fi

    cat <<EOF >> /etc/apt/sources.list

# Debian 13 Trixie Repositories
deb http://deb.debian.org/debian trixie main contrib non-free non-free-firmware
deb http://deb.debian.org/debian trixie-updates main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security trixie-security main contrib non-free non-free-firmware
EOF

  else
    echo "Invalid selection."
    exit 1
  fi

  echo "Running upgrade process..."

  apt update
  apt full-upgrade -y $APT_OPTS
  apt autoremove -y
  apt clean
  apt purge -y '~c'

  echo "Debian upgrade process completed."
  exit 0
fi

# --------------------------------------------------
# Option 4: Parrot Linux Conversion
# --------------------------------------------------
if [[ "$CHOICE" == "4" ]]; then
  echo "WARNING: This will convert Debian into Parrot Linux."
  read -rp "Type CONVERT to proceed: " PARROT_CONFIRM
  [[ "$PARROT_CONFIRM" != "CONVERT" ]] && exit 1

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
echo "Select Debian target:"
echo "1) Debian 12 (Bookworm)"
echo "2) Debian 13 (Trixie - TESTING)"
read -rp "Choice [1-2]: " TARGET

# Backup sources.list
cp /etc/apt/sources.list /etc/apt/sources.list.bak.$(date +%F)

# Comment out existing entries
sed -i 's/^[^#]/#&/' /etc/apt/sources.list

# --------------------------------------------------
# Debian 12
# --------------------------------------------------
if [[ "$TARGET" == "1" ]]; then
  cat <<EOF >> /etc/apt/sources.list

# Debian 12 Bookworm Repositories
deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware
deb http://deb.debian.org/debian bookworm-updates main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware
EOF

  apt update
  apt full-upgrade -y $APT_OPTS
  echo "Upgrade to Debian 12 completed."
  exit 0
fi

# --------------------------------------------------
# Debian 13 (Double Confirmation)
# --------------------------------------------------
if [[ "$TARGET" == "2" ]]; then
  echo "WARNING: Debian 13 (Trixie) is TESTING."
  read -rp "Type I UNDERSTAND to continue: " CONFIRM1
  read -rp "Type UPGRADE TO 13 to confirm: " CONFIRM2

  if [[ "$CONFIRM1" != "I UNDERSTAND" || "$CONFIRM2" != "UPGRADE TO 13" ]]; then
    echo "Upgrade aborted."
    exit 1
  fi

  cat <<EOF >> /etc/apt/sources.list

# Debian 13 Trixie Repositories
deb http://deb.debian.org/debian trixie main contrib non-free non-free-firmware
deb http://deb.debian.org/debian trixie-updates main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security trixie-security main contrib non-free non-free-firmware
EOF

  apt update
  apt full-upgrade -y $APT_OPTS
  apt autoremove -y
  apt clean
  apt purge -y '~c'

  echo "Upgrade to Debian 13 completed."
  exit 0
fi

echo "Unknown error occurred."
exit 1