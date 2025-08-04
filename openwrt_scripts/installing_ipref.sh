#!/bin/sh

echo "[+] Updating package list..."
opkg update

echo "[+] Installing iperf3..."
opkg install iperf3

echo "[+] Creating init script..."
cat << 'EOF' > /etc/init.d/iperf3-server
#!/bin/sh /etc/rc.common
# Custom init script to run iperf3 server on boot

START=99

start() {
    logger -t iperf3 "Starting iperf3 server on boot"
    iperf3 -s -D
}

stop() {
    logger -t iperf3 "Stopping iperf3 server"
    killall iperf3
}
EOF

echo "[+] Making script executable..."
chmod +x /etc/init.d/iperf3-server

echo "[+] Enabling iperf3 to start at boot..."
/etc/init.d/iperf3-server enable

echo "[+] Starting iperf3 server now..."
/etc/init.d/iperf3-server start

echo "[✓] iperf3 is now running and will auto-start on boot."