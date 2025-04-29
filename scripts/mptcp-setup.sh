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
    

WAN_INTERFACES=()

# FIXME: No interfaces has been found
for iface in $(ip link show | grep -E 'eth[0-9]|enp[0-9]s[0-9]' | awk -F': ' '{print $2}' | grep -v "$LAN_INTERFACE"); do

    WAN_INTERFACES+=("$iface")
done

# FIXME: No interfaces has been found
if [ -z "$WAN_INTERFACES" ]; then

    echo "ERROR: No WAN_INTERFACES"
    exit 1
fi

echo "WAN_INTERFACES='$WAN_INTERFACES'"

for iface in "${WAN_INTERFACES[@]}"; do
    
    IP_ADDR=$(ip -4 addr show dev "$iface" | grep inet | awk '{print $2}' | cut -d/ -f1)
    
    if [ -n "$IP_ADDR" ]; then
    
        echo "Creating MPTCP subflow for $iface ($IP_ADDR)"
        ip mptcp endpoint add "$IP_ADDR" dev "$iface" subflow
    fi
done

echo "Current MPTCP endpoints:"
ip mptcp endpoint show

if ! ip mptcp endpoint show | grep -q subflow; then
    
    echo "ERROR: No MPTCP subflows established"
    echo "Debug info:"
    echo "- Available interfaces:"; ip link show
    echo "- IP addresses:"; ip -4 addr show
    exit 1
fi

echo 1 > /proc/sys/net/ipv4/ip_forward

if [ -w /etc/sysctl.conf ]; then
    
    echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
fi

if [ "$(cat /proc/sys/net/ipv4/ip_forward)" -ne 1 ]; then
    
    echo "ERROR: Failed to enable IP forwarding!" >&2
    exit 1
fi

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