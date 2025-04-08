#!/bin/bash

# Load environment variables
if [ -f /etc/netplan_optimizer/notifications.yaml ]; then
    export $(grep -v '^#' /etc/netplan_optimizer/notifications.yaml | xargs)
fi

# Start main application
if [ "$1" = "cron" ]; then
    echo "Starting in cron mode..."
    while true; do
        python netplan_optimizer.py --cron
        sleep ${BENCHMARK_INTERVAL:-3600}
    done
else
    python netplan_optimizer.py
fi