#!/bin/bash

if ! scripts/ethernets-up.sh; then

    echo "ERROR: Failed to bring up Ethernet interfaces"
    exit 1
fi

. scripts/detect-gate.sh

if detect_gate; then

    if [ -z "$LAN_GATE_INTERFACE" ]; then
      
        echo "ERROR: LAN_GATE_INTERFACE is not set, please check the detect-gate.sh script"
        exit 1
    fi
    
    echo "LAN_GATE_INTERFACE: $LAN_GATE_INTERFACE"

else
    
    echo "ERROR: Failed to detect LAN gateway interface"
    exit 1
fi

if sudo apt update && \
    sudo apt install -y \
    iptables-persistent netfilter-persistent \
    iftop ethtool && \
    ((sudo systemctl stop systemd-resolved && sudo systemctl disable systemd-resolved && sudo systemctl mask systemd-resolved && echo "systemd-resolved is off (1)") || echo "systemd-resolved is off (2)") && \
    (sudo pkill -9 dnsmasq || echo "No dnsmasq instances left") && \
    (sudo fuser -k 53/udp || echo "Port 53 is free") && \
    (test -e /etc/resolv.conf.backup && echo "resolv.conf.backup ok") || (sudo mv /etc/resolv.conf /etc/resolv.conf.backup && echo "resolv.conf.backup created") && \
    echo "nameserver 1.1.1.1" | sudo tee /etc/resolv.conf && \
    docker-compose build && \
    docker-compose up -d && \
    echo "Installation has been completed"; then

    echo "Waiting for containers to start..." && sleep 10

    if docker exec mptcp-router ps aux | grep -q [d]nsmasq; then
        echo "Verification step 1 SUCCESS - dnsmasq running"
    else
        echo "ERROR: Verification step 1 FAILURE - dnsmasq not running"
        docker exec mptcp-router ps aux
        exit 1
    fi

    if docker exec mptcp-router ss -ulnp | grep -q dnsmasq; then
        echo "Verification step 2 SUCCESS - dnsmasq bound to port"
    else
        echo "ERROR: Verification step 2 FAILURE - dnsmasq not bound"
        docker exec mptcp-router ss -ulnp
        exit 1
    fi

    if docker exec mptcp-router ip mptcp endpoint show | grep -q subflow; then
        echo "Verification step 3 SUCCESS - MPTCP active"
    else
        echo "ERROR: Verification step 3 FAILURE - No MPTCP endpoints"
        docker exec mptcp-router ip mptcp endpoint show
        exit 1
    fi    

    if docker exec mptcp-router ethtool "$LAN_GATE_INTERFACE" | grep "Link detected" && \
        sudo iptables -L INPUT -nv | grep -E '67|68' && \
        docker exec mptcp-router ss -ulnp | grep dnsmasq; then
        echo "Verification step 4 SUCCESS - Final check"
    else
        echo "ERROR: Verification step 4 FAILURE - Final check failed"
        exit 1
    fi
fi
