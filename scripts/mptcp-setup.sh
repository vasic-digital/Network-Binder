#!/bin/bash

# 1. Stop existing dnsmasq and free port 53
echo "Cleaning up conflicts..."
pkill dnsmasq || true
fuser -k 53/tcp 53/udp || true  # Force-release ports

# 2. Enable MPTCP
sysctl -w net.mptcp.enabled=1
[ -f /proc/sys/net/mptcp/mptcp_path_manager ] && \
    sysctl -w net.mptcp.mptcp_path_manager=fullmesh

# 3. Configure network (DHCP for WAN, static for LAN)
python3 /app/auto-detector.py  # Generates /etc/netplan/50-cloud-init.yaml
netplan apply

# 4. Set up NAT
iptables -t nat -A POSTROUTING -o eth+ -j MASQUERADE
echo 1 > /proc/sys/net/ipv4/ip_forward

# 5. Start dnsmasq (retry if port 53 is still busy)
for attempt in {1..3}; do
    dnsmasq \
        --interface="$LAN_INTERFACE" \
        --dhcp-range=192.168.0.100,192.168.0.200,24h \
        --dhcp-option=3,192.168.0.1 \
        --dhcp-option=6,1.1.1.1,8.8.8.8 \
        --no-daemon &
    sleep 1
    if ps -p $! >/dev/null; then
        echo "dnsmasq started successfully"
        break
    elif [ $attempt -eq 3 ]; then
        echo "Failed to start dnsmasq after 3 attempts"
        exit 1
    fi
done

# Keep container running
while true; do sleep 3600; done