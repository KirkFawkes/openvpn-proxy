#!/bin/bash
set -e

# Create tun device if it doesn't exist
if [ ! -c /dev/net/tun ]; then
    mkdir -p /dev/net
    mknod /dev/net/tun c 10 200
    chmod 600 /dev/net/tun
fi

# Check if TUN device is available
if [ ! -c /dev/net/tun ]; then
    echo "ERROR: TUN/TAP device is not available. Cannot run OpenVPN."
    exit 1
fi

# Check IP forwarding (but don't try to enable it in the container)
echo "Checking IP forwarding status..."
if [ "$(cat /proc/sys/net/ipv4/ip_forward)" = "1" ]; then
    echo "IP forwarding is already enabled on host"
else
    echo "WARNING: IP forwarding is not enabled on host. VPN routing may not work properly."
    echo "Run this on the host system: 'sudo sysctl -w net.ipv4.ip_forward=1'"
    echo "To make it permanent: 'echo \"net.ipv4.ip_forward = 1\" | sudo tee -a /etc/sysctl.conf'"
fi

# Execute the command passed to docker
echo "Starting OpenVPN with command: $@"
exec "$@"
