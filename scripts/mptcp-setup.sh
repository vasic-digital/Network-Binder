#!/bin/bash

# Wait for network interfaces
sleep 5

# Enable MPTCP
echo "Enabling MPTCP..."
sysctl -w net.mptcp.enabled=1
[ -f /proc/sys/net/mptcp/mptcp_path_manager ] && \
    sysctl -w net.mptcp.mptcp_path_manager=fullmesh

# Run auto-detector
echo "Detecting interfaces..."
python3 /app/auto-detector.py

# Apply network config
echo "Applying network configuration..."
if command -v netplan >/dev/null; then
    netplan generate
    ip link set eth0 down 2>/dev/null || true
    ip link set eth0 up 2>/dev/null || true
else
    echo "Using fallback network configuration"
    # Add your specific interface commands here
fi

# Set up NAT
echo "Configuring iptables..."
iptables -t nat -A POSTROUTING -o eth+ -j MASQUERADE
echo 1 > /proc/sys/net/ipv4/ip_forward

# Start DHCP
echo "Starting dnsmasq..."
pkill dnsmasq || true
if [ -n "$LAN_INTERFACE" ]; then
    dnsmasq \
        --interface="$LAN_INTERFACE" \
        --dhcp-range=192.168.0.100,192.168.0.200,24h \
        --dhcp-option=3,192.168.0.1 \
        --dhcp-option=6,1.1.1.1,8.8.8.8 \
        --no-daemon &
fi

echo "MPTCP router started successfully"
while true; do sleep 3600; done