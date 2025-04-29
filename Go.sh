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

    V="$(docker exec -it mptcp-router ps aux | grep dnsmasq)"

    if [ -z "$V" ]; then

        echo "ERROR: Verification step 1 FAILURE"
        exit 1
    fi

    echo "Verification step 1 SUCCESS"

    V="$(docker exec -it mptcp-router tail -f /var/log/syslog | grep dnsmasq)"

    if [ -z "$V" ]; then

        echo "ERROR: Verification step 2 FAILURE"
        exit 1
    fi

    echo "Verification step 2 SUCCESS"

    V="$(docker exec -it mptcp-router ip mptcp endpoint show)"

    if [ -z "$V" ]; then

        echo "ERROR: Verification step 3 FAILURE"
        exit 1
    fi

    echo "Verification step 3 SUCCESS"
fi
