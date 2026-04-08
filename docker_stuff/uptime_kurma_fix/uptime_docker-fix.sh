#!/usr/bin/env bash
set -euo pipefail

# setup-docker-remote-api.sh
# Enables Docker remote API on tcp://0.0.0.0:2375 using a systemd override.
# Optional: lock port 2375 down to a single source IP.
#
# Usage:
#   sudo bash setup-docker-remote-api.sh
#   sudo bash setup-docker-remote-api.sh --allow-ip 10.0.84.50
#
# Notes:
# - This exposes the Docker API over unencrypted TCP.
# - Anyone who can reach port 2375 can effectively control Docker on the host.
# - Strongly recommended: use --allow-ip with your Uptime Kuma server IP.

ALLOW_IP=""
OVERRIDE_DIR="/etc/systemd/system/docker.service.d"
OVERRIDE_FILE="${OVERRIDE_DIR}/override.conf"
BACKUP_SUFFIX="$(date +%Y%m%d-%H%M%S)"

usage() {
  cat <<EOF
Usage:
  sudo bash $0 [--allow-ip IP]

Options:
  --allow-ip IP    Allow only this source IP to access TCP 2375 using iptables.
  -h, --help       Show this help.

Examples:
  sudo bash $0
  sudo bash $0 --allow-ip 10.0.84.50
EOF
}

log() {
  echo "[INFO] $*"
}

warn() {
  echo "[WARN] $*" >&2
}

err() {
  echo "[ERROR] $*" >&2
}

require_root() {
  if [[ "${EUID}" -ne 0 ]]; then
    err "Run this script as root or with sudo."
    exit 1
  fi
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --allow-ip)
        shift
        [[ $# -gt 0 ]] || { err "Missing value for --allow-ip"; exit 1; }
        ALLOW_IP="$1"
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        err "Unknown argument: $1"
        usage
        exit 1
        ;;
    esac
    shift
  done
}

check_prereqs() {
  command -v systemctl >/dev/null 2>&1 || { err "systemctl not found."; exit 1; }
  command -v docker >/dev/null 2>&1 || { err "docker not found."; exit 1; }
  command -v ss >/dev/null 2>&1 || { err "ss not found."; exit 1; }
  command -v curl >/dev/null 2>&1 || { err "curl not found."; exit 1; }

  if ! systemctl list-unit-files | grep -q '^docker.service'; then
    err "docker.service not found."
    exit 1
  fi
}

backup_existing_override() {
  mkdir -p "${OVERRIDE_DIR}"

  if [[ -f "${OVERRIDE_FILE}" ]]; then
    cp -a "${OVERRIDE_FILE}" "${OVERRIDE_FILE}.bak.${BACKUP_SUFFIX}"
    log "Backed up existing override to ${OVERRIDE_FILE}.bak.${BACKUP_SUFFIX}"
  fi
}

write_override() {
  cat > "${OVERRIDE_FILE}" <<'EOF'
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H fd:// -H tcp://0.0.0.0:2375 --containerd=/run/containerd/containerd.sock
EOF

  log "Wrote Docker systemd override: ${OVERRIDE_FILE}"
}

reload_and_restart() {
  log "Reloading systemd..."
  systemctl daemon-reload

  log "Restarting Docker..."
  systemctl restart docker

  log "Checking Docker service status..."
  systemctl --no-pager --full status docker.service || true
}

verify_listener() {
  log "Verifying Docker is listening on TCP 2375..."
  if ss -lntp | grep -q ':2375'; then
    ss -lntp | grep ':2375' || true
    log "Docker is listening on port 2375."
  else
    err "Docker is not listening on port 2375."
    exit 1
  fi
}

verify_local_api() {
  log "Verifying local Docker API response..."
  if curl -fsS http://127.0.0.1:2375/version >/dev/null; then
    curl -fsS http://127.0.0.1:2375/version
    echo
    log "Local Docker API test succeeded."
  else
    err "Local Docker API test failed."
    exit 1
  fi
}

configure_firewall() {
  if [[ -z "${ALLOW_IP}" ]]; then
    warn "No --allow-ip provided. Port 2375 will remain reachable by anything that can route to this host."
    return
  fi

  command -v iptables >/dev/null 2>&1 || {
    warn "iptables not found. Skipping firewall rules."
    return
  }

  log "Applying iptables rules to allow only ${ALLOW_IP} to TCP 2375..."

  # Avoid duplicate rules
  iptables -C INPUT -p tcp -s "${ALLOW_IP}" --dport 2375 -j ACCEPT 2>/dev/null || \
    iptables -A INPUT -p tcp -s "${ALLOW_IP}" --dport 2375 -j ACCEPT

  iptables -C INPUT -p tcp --dport 2375 -j DROP 2>/dev/null || \
    iptables -A INPUT -p tcp --dport 2375 -j DROP

  log "iptables rules applied."
  warn "Make sure your firewall rules are saved persistently on this host."
}

show_summary() {
  echo
  echo "Done."
  echo
  echo "Docker remote API should now be available at:"
  echo "  tcp://$(hostname -I | awk '{print $1}'):2375"
  echo
  echo "Use this in Uptime Kuma:"
  echo "  tcp://HOST_IP:2375"
  echo
  if [[ -n "${ALLOW_IP}" ]]; then
    echo "Access restricted to source IP:"
    echo "  ${ALLOW_IP}"
  else
    echo "No IP restriction was applied."
  fi
  echo
}

main() {
  require_root
  parse_args "$@"
  check_prereqs
  backup_existing_override
  write_override
  reload_and_restart
  verify_listener
  verify_local_api
  configure_firewall
  show_summary
}

main "$@"
