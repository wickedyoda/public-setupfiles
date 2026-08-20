#!/bin/bash
# =============================================================================
# WireGuard Client Autoconnect Installer for Flint4
# For Debian/Ubuntu systems connecting to Flint4 router at twy4us.duckdns.org
# =============================================================================
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

TUNNEL_NAME="wgclient2"
PEER_HOST="twy4us.duckdns.org"
CONFIG_DIR="/etc/wireguard"
CONFIG_FILE="${CONFIG_DIR}/${TUNNEL_NAME}.conf"
SERVICE_NAME="wg-${TUNNEL_NAME}"

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

if [[ $EUID -ne 0 ]]; then
    error "This script must be run as root (use sudo)"
    exit 1
fi

if ! command -v apt-get &>/dev/null; then
    error "This script is for Debian/Ubuntu systems only"
    exit 1
fi

# Step 1: Install WireGuard
info "Checking for WireGuard installation..."
if ! command -v wg &>/dev/null; then
    info "Installing WireGuard..."
    apt-get update -qq
    apt-get install -y -qq wireguard wireguard-tools
    success "WireGuard installed"
else
    success "WireGuard already installed"
fi

# Step 2: Get config file path
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE} WireGuard Client Installer${NC}"
echo -e "${BLUE}========================================${NC}"
echo "This script will set up a WireGuard client tunnel '${TUNNEL_NAME}'"
echo "to connect to: ${PEER_HOST}"
echo ""
read -rp "Enter the path to your WireGuard config file (e.g., /root/wg0.conf, ~/wireguard.conf): " CONFIG_SOURCE

CONFIG_SOURCE="${CONFIG_SOURCE/#\~/$HOME}"

if [[ ! -f "$CONFIG_SOURCE" ]]; then
    error "Config file not found: $CONFIG_SOURCE"
    exit 1
fi

if ! grep -q "\[Interface\]" "$CONFIG_SOURCE" || ! grep -q "\[Peer\]" "$CONFIG_SOURCE"; then
    error "Invalid WireGuard config (missing [Interface] or [Peer] section)"
    exit 1
fi

success "Config file verified: $CONFIG_SOURCE"

# Step 3: Install config
info "Installing config to ${CONFIG_FILE}..."
mkdir -p "$CONFIG_DIR"
cp "$CONFIG_SOURCE" "$CONFIG_FILE"
chmod 600 "$CONFIG_FILE"
success "Config installed"

# Step 4: Create systemd service
info "Creating systemd service..."
cat > /etc/systemd/system/${SERVICE_NAME}.service << EOF
[Unit]
Description=WireGuard via wg-quick(8) for ${TUNNEL_NAME}
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/bin/wg-quick up ${TUNNEL_NAME}
ExecStop=/usr/bin/wg-quick down ${TUNNEL_NAME}
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable "${SERVICE_NAME}"
success "Service created and enabled for boot"

# Step 5: Start the tunnel
info "Starting WireGuard tunnel..."
wg-quick up "$TUNNEL_NAME"
success "Tunnel is UP"

# Step 6: Verify
sleep 2
if ip link show "$TUNNEL_NAME" &>/dev/null; then
    success "Interface ${TUNNEL_NAME} is active"
    echo ""
    echo "Tunnel details:"
    ip addr show "$TUNNEL_NAME"
    echo ""
    echo "WireGuard status:"
    wg show "$TUNNEL_NAME"
else
    error "Interface not found. Check config and run: wg-quick up ${TUNNEL_NAME}"
    exit 1
fi

# Summary
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN} WireGuard Client Setup Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Tunnel:     ${TUNNEL_NAME}"
echo "Peer:       ${PEER_HOST}"
echo "Config:     ${CONFIG_FILE}"
echo "Service:    ${SERVICE_NAME}"
echo ""
echo "Commands:"
echo "  wg-quick up ${TUNNEL_NAME}       - Bring up"
echo "  wg-quick down ${TUNNEL_NAME}     - Bring down"
echo "  wg show ${TUNNEL_NAME}            - Show status"
echo "  systemctl status ${SERVICE_NAME}  - Service status"
echo ""
echo -e "${GREEN}Tunnel starts automatically on boot.${NC}"
