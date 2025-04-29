#!/bin/bash

# Wait for interfaces to be available
sleep 5

# Enable MPTCP (skip if kernel doesn't support all features)
sysctl -w net.mptcp.enabled=1
[ -f /proc/sys/net/mptcp/mptcp_path_manager ] && \
    sysctl -w net.mptcp.mptcp_path_manager=fullmesh

# Run auto-detector
python3 /app/auto-detector.py

# Apply config
netplan apply

# Set up NAT (only if iptables is available)
if command -