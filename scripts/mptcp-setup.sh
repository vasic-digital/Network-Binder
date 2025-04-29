#!/bin/bash

[ -z "$LAN_INTERFACE" ] && { echo "ERROR: LAN_INTERFACE not set"; exit 1; }

if ! ip link show "$LAN_INTERFACE" >/dev/null 2>&1; then
    
    echo "ERROR: Interface '$LAN_INTERFACE' missing. Available:"
    ip -brief link show
    exit 1
fi

sysctl -w net.mptcp.enabled=1
[ -f /proc/sys/net/mptcp/mptcp_path_manager ] && \
    sysctl -w net.mptcp.mptcp_path_manager=fullmesh

echo 1 > /proc/sys/net/ipv4/ip_forward

iptables -t nat -F
iptables -t nat -A POSTROUTING -s 192.168.0.0/24 -o eth+ -j MASQUERADE

if ! iptables -t nat -L POSTROUTING -nv | grep -q "MASQUERADE.*eth+"; then

    echo "ERROR: NAT configuration failed" >&2
    exit 1
fi

pkill -9 dnsmasq || true
fuser -k 67/udp || true

dnsmasq \
    --log-facility=/var/log/dnsmasq.log \
    --log-dhcp \
    --log-queries \
    --bind-interfaces \
    --interface="$LAN_INTERFACE" \
    --except-interface=lo \
    --dhcp-range=192.168.0.100,192.168.0.200,24h \
    --dhcp-option=3,192.168.0.1 \
    --dhcp-option=6,1.1.1.1,8.8.8.8 \
    --no-resolv \
    --server=1.1.1.1 \
    --server=8.8.8.8 \
    --no-daemon &

sleep 2

if ! ps -p $! >/dev/null; then
 
    echo "ERROR: dnsmasq failed to start. Check:"
    tail -n 20 /var/log/dnsmasq.log
    exit 1
fi

echo "MPTCP router operational. Monitoring logs..."

tail -f /var/log/dnsmasq.log