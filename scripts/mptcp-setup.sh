#!/bin/bash

# 1. Stop existing dnsmasq and free port 53
echo "Stopping conflicting services..."
pkill dnsmasq || true
fuser -k 53/udp || true
sleep 2

# 2. Enable MPTCP
sysctl -w net.mptcp.enabled=1
[ -f /proc/sys/net/mptcp/mptcp_path_manager ] && \
    sysctl -w net.mptcp.mptcp_path_manager=fullmesh

# 3. Configure network (skip systemd-dependent netplan apply)
python3 /app/auto-detector.py
netplan generate
ip link set eth0 down 2>/dev/null || true
ip link set eth0 up 2>/dev/null || true

# 4. Set up NAT
iptables -t nat -A POSTROUTING -o eth+ -j MASQUERADE
echo 1 > /proc/sys/net/ipv4/ip_forward

# 5. Start dnsmasq (with strict interface binding)
echo "Starting dnsmasq..."
dnsmasq \
    --bind-interfaces \
    --interface="$LAN_INTERFACE" \
    --dhcp-range=192.168.0.100,192.168.0.200,24h \
    --dhcp-option=3,192.168.0.1 \
    --dhcp-option=6,1.1.1.1,8.8.8.8 \
    --no-daemon &

# 6. Verify dnsmasq is running
sleep 2
if ! ps -aux | grep -v grep | grep dnsmasq; then
    echo "ERROR: dnsmasq failed to start"
    exit 1
fi

echo "MPTCP router is running"
while true; do sleep 3600; done