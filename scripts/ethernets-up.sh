#!/bin/bash

if ! sudo ip link set up dev $(ip -o link | awk -F': ' '$2 ~ /^e/ {print $2}'); then

    echo "ERROR: Failed to bring up Ethernet interfaces"
    exit 1
fi