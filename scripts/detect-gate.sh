#!/bin/bash

. ~/.bashrc
. /etc/environment

if [ -z "$LAN_GATE_MAC" ]; then
    
    echo "Please set the LAN_GATE_MAC environment variable to the MAC address of the LAN gateway."
    exit 1
fi

# Find the interface with the matching MAC address
LAN_INTERFACE=$(ip link show | grep -B1 "$LAN_MAC" | awk -F': ' 'NR==1{print $2}')

if [[ -n "$LAN_INTERFACE" ]]; then
    
    echo "LAN interface detected: $LAN_INTERFACE"

    export LAN_GATE_INTERFACE="$LAN_INTERFACE"
    
else
    
    echo "No LAN interface found with MAC address $LAN_MAC."
    exit 1
fi