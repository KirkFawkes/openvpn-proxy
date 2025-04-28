#!/bin/bash

MAX_TRIES=30
SLEEP_INTERVAL=2
counter=0

echo "Waiting for VPN tunnel interface to become available..."

while [ $counter -lt $MAX_TRIES ]; do
    # Check if tun0 interface exists and is up
    if ip addr show tun0 2>/dev/null | grep -q "state UP"; then
        echo "VPN tunnel interface (tun0) is UP and ready!"
        break
    fi
    
    # Check for other tun interfaces if tun0 isn't available
    if ip addr | grep -q "tun[0-9]"; then
        TUN_IFACE=$(ip addr | grep -o "tun[0-9]" | head -n 1)
        echo "Found VPN interface: $TUN_IFACE instead of tun0"
        
        # Create a dynamic sockd.conf with the correct interface
        cat > /etc/sockd/sockd.conf << EOL
logoutput: stderr
internal: 0.0.0.0 port = 1080
external: $TUN_IFACE
clientmethod: none
socksmethod: none
user.privileged: root
user.notprivileged: nobody
timeout.io: 60
timeout.negotiate: 30
timeout.connect: 30

client pass {
    from: 0.0.0.0/0
    to: 0.0.0.0/0
    log: error
}
socks pass {
    from: 0.0.0.0/0
    to: 0.0.0.0/0
    log: error
}
EOL
        echo "Created configuration with $TUN_IFACE interface"
        break
    fi
    
    echo "Waiting for VPN connection... ($(($counter+1))/$MAX_TRIES)"
    counter=$((counter+1))
    sleep $SLEEP_INTERVAL
done

if [ $counter -eq $MAX_TRIES ]; then
    echo "Timeout waiting for VPN interface. Will try to use default interface"
    # Create config with eth0 as a fallback
    cat > /etc/sockd/sockd.conf << EOL
logoutput: stderr
internal: 0.0.0.0 port = 1080
external: eth0
clientmethod: none
socksmethod: none
user.privileged: root
user.notprivileged: nobody
timeout.io: 60
timeout.negotiate: 30
timeout.connect: 30

client pass {
    from: 0.0.0.0/0
    to: 0.0.0.0/0
    log: error
}
socks pass {
    from: 0.0.0.0/0
    to: 0.0.0.0/0
    log: error
}
EOL
fi

# Start the SOCKS proxy
echo "Starting SOCKS5 proxy on port 1080"
exec sockd -f /etc/sockd/sockd.conf -N 100
