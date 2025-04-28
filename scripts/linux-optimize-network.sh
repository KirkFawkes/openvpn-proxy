#!/bin/bash

# Enable IP forwarding (required for VPN)
sysctl -w net.ipv4.ip_forward=1

# Increase TCP connection queue
sysctl -w net.core.somaxconn=1024
sysctl -w net.ipv4.tcp_max_syn_backlog=1024

# Enable TCP SYN cookies (protection against SYN flood attacks)
sysctl -w net.ipv4.tcp_syncookies=1

# Decrease TCP FIN timeout
sysctl -w net.ipv4.tcp_fin_timeout=30

# Increase TCP read/write buffer limits
sysctl -w net.core.rmem_max=16777216
sysctl -w net.core.wmem_max=16777216

# Set min/default/max TCP read buffer
sysctl -w net.ipv4.tcp_rmem="4096 87380 16777216"

# Set min/default/max TCP write buffer
sysctl -w net.ipv4.tcp_wmem="4096 65536 16777216"

# Make the changes permanent (optional)
echo "# Network performance optimizations" >> /etc/sysctl.conf
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
echo "net.core.somaxconn=1024" >> /etc/sysctl.conf
echo "net.ipv4.tcp_max_syn_backlog=1024" >> /etc/sysctl.conf
echo "net.ipv4.tcp_syncookies=1" >> /etc/sysctl.conf
echo "net.ipv4.tcp_fin_timeout=30" >> /etc/sysctl.conf
echo "net.core.rmem_max=16777216" >> /etc/sysctl.conf
echo "net.core.wmem_max=16777216" >> /etc/sysctl.conf
echo "net.ipv4.tcp_rmem=4096 87380 16777216" >> /etc/sysctl.conf
echo "net.ipv4.tcp_wmem=4096 65536 16777216" >> /etc/sysctl.conf

echo "Network optimizations applied successfully!"
