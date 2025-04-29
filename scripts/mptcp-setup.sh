#!/bin/bash

if [ -z "$LAN_INTERFACE" ]; then

    echo "ERROR: LAN_INTERFACE is not set"
    exit 1
fi

if ! ip link show "$LAN_INTERFACE" >/dev/null 2>&1; then
  
    echo "ERROR: Interface '$LAN_INTERFACE' does not exist"
    ip link show
    exit 1
fi

echo "Stopping conflicts... (if any)"
pkill dnsmasq || true
ss -ulpn 'sport = 53' | awk '{print $6}' | cut -d'"' -f2 | xargs -r kill || true
sleep 2

sysctl -w net.mptcp.enabled=1
[ -f /proc/sys/net/mptcp/mptcp_path_manager ] && \
    sysctl -w net.mptcp.mptcp_path_manager=fullmesh

echo "Starting dnsmasq on '$LAN_INTERFACE' ..."
dnsmasq \
    --log-facility=/var/log/dnsmasq.log \
    --no-resolv \
    --server=1.1.1.1 \
    --server=8.8.8.8 \
    --bind-interfaces \
    --interface="$LAN_INTERFACE" \
    --dhcp-range=192.168.0.100,192.168.0.200,24h \
    --dhcp-option=3,192.168.0.1 \
    --no-daemon &

sleep 2

if ! ps -p $! >/dev/null; then

    echo "ERROR: dnsmasq failed to start"
    exit 1
fi

echo "MPTCP router is running"

tail -f /var/log/dnsmasq.log