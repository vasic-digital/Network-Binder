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
fi
