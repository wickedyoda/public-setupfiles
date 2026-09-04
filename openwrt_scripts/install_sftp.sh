#!/bin/sh
# Install and enable SFTP on OpenWrt using Dropbear.
# Run as root: sh install-sftp.sh

set -eu

log() {
    printf '%s\n' "[sftp] $*"
}

if [ "$(id -u)" -ne 0 ]; then
    printf '%s\n' "ERROR: run this script as root." >&2
    exit 1
fi

if ! command -v opkg >/dev/null 2>&1; then
    printf '%s\n' "ERROR: opkg was not found; this does not appear to be OpenWrt." >&2
    exit 1
fi

log "Updating package lists"
opkg update

if opkg list-installed 2>/dev/null |
    grep -q '^openssh-sftp-server '; then
    log "openssh-sftp-server is already installed"
else
    log "Installing openssh-sftp-server"
    opkg install openssh-sftp-server
fi

if [ ! -x /etc/init.d/dropbear ]; then
    printf '%s\n' "ERROR: Dropbear init script was not found." >&2
    exit 1
fi

log "Enabling Dropbear at boot"
/etc/init.d/dropbear enable

log "Restarting Dropbear"
/etc/init.d/dropbear restart

SFTP_SERVER=""

for candidate in \
    /usr/libexec/sftp-server \
    /usr/lib/sftp-server \
    /usr/lib/openssh/sftp-server
do
    if [ -x "$candidate" ]; then
        SFTP_SERVER="$candidate"
        break
    fi
done

if [ -z "$SFTP_SERVER" ]; then
    printf '%s\n' \
        "ERROR: SFTP server binary was not found after installation." >&2
    opkg files openssh-sftp-server 2>/dev/null || true
    exit 1
fi

log "SFTP server found at: $SFTP_SERVER"
log "SFTP installation completed"

printf '\n'
printf '%s\n' "Connect with:"
printf '%s\n' "  sftp root@<router-ip>"
printf '%s\n' "Example:"
printf '%s\n' "  sftp root@192.168.8.1"
printf '\n'
printf '%s\n' \
    "For security, use SFTP from the LAN or VPN only."