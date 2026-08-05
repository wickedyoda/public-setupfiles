#!/usr/bin/env bash
set -euo pipefail

# Update Tailscale on Debian/Ubuntu/Raspbian.
# - Ensures official repo is present (with signed-by keyring for modern releases)
# - apt-get update && apt-get install -y tailscale
# - Starts/enables tailscaled if systemd is available

REPO_FILE="/etc/apt/sources.list.d/tailscale.list"
KEYRING_DIR="/usr/share/keyrings"
KEYRING_FILE="${KEYRING_DIR}/tailscale-archive-keyring.gpg"

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Installing missing dependency: $1"
    sudo apt-get update -y
    sudo apt-get install -y "$1"
  }
}

require_root() {
  if [ "$EUID" -ne 0 ]; then
    echo "Please run as root (use: sudo bash $0)"
    exit 1
  fi
}

main() {
  require_root

  # Base dependencies
  need_cmd curl
  need_cmd tee
  need_cmd apt-get

  # Detect distro and codename
  if [ -r /etc/os-release ]; then
    . /etc/os-release
  else
    echo "Cannot read /etc/os-release; aborting."
    exit 1
  fi

  # Normalize ID to expected repo path segments
  # (tailscale supports 'debian', 'ubuntu', 'raspbian')
  case "${ID:-}" in
    debian)   repo_base="debian"   ;;
    ubuntu)   repo_base="ubuntu"   ;;
    raspbian) repo_base="raspbian" ;;
    *)
      # Some derivatives set ID_LIKE
      if [[ "${ID_LIKE:-}" =~ debian ]]; then
        # Default to debian rules for derivatives
        repo_base="debian"
      else
        echo "Unsupported distro ID: '${ID:-}' (ID_LIKE: '${ID_LIKE:-}')."
        echo "This script supports Debian, Ubuntu, or Raspbian."
        exit 1
      fi
      ;;
  esac

  codename="${VERSION_CODENAME:-}"
  if [ -z "$codename" ]; then
    # Fallback: parse from /etc/debian_version if needed
    if [ -r /etc/debian_version ] && [ "$repo_base" = "debian" ]; then
      debver="$(cut -d'.' -f1 < /etc/debian_version || true)"
      case "$debver" in
        12) codename="bookworm" ;;
        11) codename="bullseye" ;;
        10) codename="buster" ;;
        9)  codename="stretch" ;;
      esac
    fi
  fi

  if [ -z "$codename" ]; then
    echo "Could not detect VERSION_CODENAME. Aborting to avoid wrong repo."
    exit 1
  fi

  echo "Detected: ID='${ID:-unknown}' (${repo_base}), CODENAME='${codename}'."

  mkdir -p -m 0755 "$KEYRING_DIR"

  # URLs per Tailscale official instructions
  key_url="https://pkgs.tailscale.com/stable/${repo_base}/${codename}.noarmor.gpg"
  list_url="https://pkgs.tailscale.com/stable/${repo_base}/${codename}.tailscale-keyring.list"

  # Some older suites (e.g., buster/stretch) don't have *.noarmor.gpg + *.tailscale-keyring.list.
  # In that case, fall back to legacy apt-key instructions.
  use_legacy=false
  if curl -fsI "$key_url" >/dev/null 2>&1 && curl -fsI "$list_url" >/dev/null 2>&1; then
    echo "Using keyring-based repo for ${repo_base}/${codename}."
    curl -fsSL "$key_url" | tee "$KEYRING_FILE" >/dev/null
    chmod 0644 "$KEYRING_FILE"
    curl -fsSL "$list_url" | tee "$REPO_FILE" >/dev/null
  else
    echo "Keyring URLs not available for ${repo_base}/${codename}. Falling back to legacy method."
    use_legacy=true
  fi

  if [ "$use_legacy" = true ]; then
    # Legacy (deprecated) apt-key method for older releases
    # Keep this branch only for suites where keyring method isn't provided upstream.
    asc_url="https://pkgs.tailscale.com/stable/${repo_base}/${codename}.asc"
    list_legacy_url="https://pkgs.tailscale.com/stable/${repo_base}/${codename}.list"

    if ! curl -fsI "$asc_url" >/dev/null 2>&1 || ! curl -fsI "$list_legacy_url" >/dev/null 2>&1; then
      echo "No repo artifacts found for ${repo_base}/${codename}. Please upgrade your OS or install via https://tailscale.com/install.sh"
      exit 1
    fi

    need_cmd apt-key
    curl -fsSL "$asc_url" | apt-key add -
    curl -fsSL "$list_legacy_url" | tee "$REPO_FILE" >/dev/null
  fi

  echo "Refreshing package lists…"
  apt-get update -y

  echo "Installing/upgrading tailscale…"
  DEBIAN_FRONTEND=noninteractive apt-get install -y tailscale

  # Start/enable service if systemd is available
  if command -v systemctl >/dev/null 2>&1; then
    systemctl enable --now tailscaled || true
  fi

  echo "Done. Tailscale version:"
  tailscale version || true

  cat <<'EOF'

If this device hasn't been authenticated yet, run:
  sudo tailscale up

Common options:
  sudo tailscale up --accept-routes --advertise-exit-node
  sudo tailscale up --advertise-routes=10.0.0.0/16

EOF
}

main "$@"