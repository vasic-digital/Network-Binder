#!/bin/bash

for interface in $(ip -o link show | awk -F': ' '{print $2}' | grep -v "lo"); do
    
    STATUS="$(ip -o link show dev $interface | awk '{print $9}')"

    echo "Status for interface '$interface' is '$STATUS'"

    if echo "$STATUS" | grep "DOWN"; then
        
        echo "Bringing up $interface..."
        
        if ! sudo ip link set "$interface" up; then

            echo "ERROR: Could not brin up the interface '$interface'"
            exit 1
        fi

    else
        
        echo "$interface is already up"
    fi
done