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

sudo apt update && \
    sudo apt install -y \
    iptables-persistent netfilter-persistent \
    iftop ethtool && \
    docker-compose build && \
    docker-compose up -d && \
    echo "Waiting for Docker containers ..." && \
    sleep 30 && \
    sh scripts/start-service.sh
