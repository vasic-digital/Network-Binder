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

sysctl -w net.mptcp.enabled=1
[ -f /proc/sys/net/mptcp/mptcp_path_manager ] && \
    sysctl -w net.mptcp.mptcp_path_manager=fullmesh

echo "Starting dnsmasq on '$LAN_INTERFACE' ..."
dnsmasq \
    --log-facility=/var/log/dnsmasq.log \
    --log-dhcp \
    --log-queries \
    --except-interface=lo \
    --bind-interfaces \
    --interface="$LAN_INTERFACE" \
    --dhcp-range=192.168.0.100,192.168.0.200,24h \
    --dhcp-option=3,192.168.0.1 \
    --dhcp-option=6,1.1.1.1,8.8.8.8 \
    --no-resolv \
    --server=1.1.1.1 \
    --server=8.8.8.8 \
    --no-daemon &

sleep 2

if ! ps -p $! >/dev/null; then

    echo "ERROR: dnsmasq failed to start"
    exit 1
fi

if iptables -t nat -F && \
    iptables -t nat -A POSTROUTING -o eth+ -j MASQUERADE && \
    iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE && \
    iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE && \
    iptables -t nat -L POSTROUTING -n -v; then

    echo "MPTCP router is running";

else

    echo "ERROR: NAT setup failed"
fi

tail -f /var/log/dnsmasq.log
