#!/bin/bash

# Enable MPTCP
sysctl -w net.mptcp.enabled=1
sysctl -w net.mptcp.mptcp_path_manager=fullmesh

# Run auto-detector
python3 /app/auto-detector.py

# Apply config
netplan apply

# Set up NAT
iptables -t nat -A POSTROUTING -o eth+ -j MASQUERADE
echo 1 > /proc/sys/net/ipv4/ip_forward

# Start DHCP
dnsmasq \
    --interface=$LAN_INTERFACE \
    --dhcp-range=192.168.0.100,192.168.0.200,24h \
    --dhcp-option=3,192.168.0.1 \
    --dhcp-option=6,1.1.1.1,8.8.8.8 &

# Keep container running
while true; do sleep 3600; done
