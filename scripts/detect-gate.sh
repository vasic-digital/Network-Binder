#!/bin/bash

LAN_GATE_MAC=""
LAN_GATE_INTERFACE=""

. ~/.bashrc
. /etc/environment

if [ -z "$LAN_GATE_MAC" ]; then
    
    echo "Please set the LAN_GATE_MAC environment variable to the MAC address of the LAN gateway."
    exit 1
fi

LAN_INTERFACE=$(ip -o link | awk -F': ' -v mac="$LAN_GATE_MAC" '$0 ~ mac {print $2}' | cut -d' ' -f1)

echo "Interface: '$LAN_INTERFACE' for mac '$LAN_GATE_MAC'"

if [ -z "$LAN_INTERFACE" ]; then

    echo "No LAN interface found with MAC address '$LAN_GATE_MAC'"
    exit 1
fi

# if [[ "$LAN_INTERFACE" == *"lo"* ]]; then
    
#     echo "ERROR: The detected interface is a loopback interface, lease check the MAC address"
#     exit 1
# fi

export LAN_GATE_INTERFACE="$LAN_INTERFACE"

echo "LAN interface detected: $LAN_GATE_INTERFACE"
