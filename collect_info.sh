#!/usr/bin/env bash

set -euo pipefail

OUTPUT="./info.txt"

#--------------------------------------------------
# Detect OS and package manager
#--------------------------------------------------
if [ -r /etc/os-release ]; then
    . /etc/os-release
    DISTRO="$ID"
    DISTRO_NAME="$PRETTY_NAME"
else
    DISTRO="unknown"
    DISTRO_NAME="Unknown Linux"
fi

if command -v apt-get >/dev/null 2>&1; then
    PKG_INSTALL="apt-get install -y"
    PKG_UPDATE="apt-get update"
elif command -v dnf >/dev/null 2>&1; then
    PKG_INSTALL="dnf install -y"
    PKG_UPDATE=":"
elif command -v yum >/dev/null 2>&1; then
    PKG_INSTALL="yum install -y"
    PKG_UPDATE=":"
elif command -v pacman >/dev/null 2>&1; then
    PKG_INSTALL="pacman -Sy --noconfirm"
    PKG_UPDATE=":"
elif command -v apk >/dev/null 2>&1; then
    PKG_INSTALL="apk add"
    PKG_UPDATE="apk update"
elif command -v zypper >/dev/null 2>&1; then
    PKG_INSTALL="zypper --non-interactive install"
    PKG_UPDATE="zypper refresh"
else
    echo "Unsupported package manager."
    exit 1
fi

run_install() {
    if [ "$EUID" -eq 0 ]; then
        eval "$PKG_UPDATE"
        eval "$PKG_INSTALL $*"
    elif command -v sudo >/dev/null 2>&1; then
        sudo bash -c "$PKG_UPDATE"
        sudo bash -c "$PKG_INSTALL $*"
    else
        echo "Cannot install packages (sudo not found)."
    fi
}

#--------------------------------------------------
# Ensure commands exist
#--------------------------------------------------

need_cmd() {
    local cmd="$1"
    shift

    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Installing package(s): $*"
        run_install "$@"
    fi
}

case "$DISTRO" in
    debian|ubuntu|linuxmint|pop)
        need_cmd lspci pciutils
        need_cmd lsusb usbutils
        need_cmd xrandr x11-xserver-utils
        ;;
    fedora|rhel|centos|rocky|almalinux)
        need_cmd lspci pciutils
        need_cmd lsusb usbutils
        need_cmd xrandr xrandr
        ;;
    arch|manjaro)
        need_cmd lspci pciutils
        need_cmd lsusb usbutils
        need_cmd xrandr xorg-xrandr
        ;;
    alpine)
        need_cmd lspci pciutils
        need_cmd lsusb usbutils
        need_cmd xrandr xrandr
        ;;
    opensuse*|sles)
        need_cmd lspci pciutils
        need_cmd lsusb usbutils
        need_cmd xrandr xrandr
        ;;
    *)
        need_cmd lspci pciutils || true
        need_cmd lsusb usbutils || true
        need_cmd xrandr xrandr || true
        ;;
esac

#--------------------------------------------------
# Collect Information
#--------------------------------------------------

{
echo "=================================================="
echo "System Information Report"
echo "=================================================="
echo

echo "Date: $(date)"
echo "Distribution: $DISTRO_NAME"
echo

echo "===== HOSTNAME ====="
hostnamectl 2>/dev/null || hostname
echo

echo "===== KERNEL ====="
uname -a
echo

echo "===== CPU ====="
lscpu 2>/dev/null
echo

echo "===== MEMORY ====="
free -h 2>/dev/null
echo

echo "===== STORAGE ====="
lsblk -o NAME,SIZE,FSTYPE,TYPE,MOUNTPOINT,MODEL
echo

echo "===== GPU ====="
lspci | grep -Ei 'vga|3d|display'
echo

echo "===== PCI DEVICES ====="
lspci
echo

echo "===== USB DEVICES ====="
lsusb
echo

echo "===== NETWORK ====="
ip addr
echo

echo "===== ROUTES ====="
ip route
echo

echo "===== DNS ====="
cat /etc/resolv.conf
echo

echo "===== DISPLAY ====="

if command -v xrandr >/dev/null 2>&1; then
    echo "--- xrandr ---"
    DISPLAY=${DISPLAY:-:0} xrandr --current 2>/dev/null || true
    echo
fi

if [ -f /sys/class/graphics/fb0/virtual_size ]; then
    echo "--- framebuffer ---"
    cat /sys/class/graphics/fb0/virtual_size
    echo
fi

for f in /sys/class/drm/card*-*/modes; do
    [ -f "$f" ] || continue
    echo "--- $(basename "$(dirname "$f")") ---"
    cat "$f"
    echo
done

echo "===== CONNECTED DISPLAYS ====="
for f in /sys/class/drm/card*-*/status; do
    [ -f "$f" ] || continue
    printf "%-30s %s\n" "$(basename "$(dirname "$f")")" "$(cat "$f")"
done

} > "$OUTPUT"

echo
echo "Report saved to: $(realpath "$OUTPUT")"