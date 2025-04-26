#!/bin/bash

SERVICE_NAME="mptcp-router"
SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME.service"

if systemctl is-active --quiet "$SERVICE_NAME"; then
    
    echo "Stopping the $SERVICE_NAME service..."
    sudo systemctl stop "$SERVICE_NAME"
fi

if [ -f "$SERVICE_FILE" ]; then
    
    echo "Removing the existing $SERVICE_FILE..."
    sudo rm "$SERVICE_FILE"
fi

echo "Copying the new service file to $SERVICE_FILE..."
sudo cp $SERVICE_NAME.service "$SERVICE_FILE"

echo "Reloading systemd daemon..."
sudo systemctl daemon-reload

echo "Enabling and starting the $SERVICE_NAME service..."
sudo systemctl enable --now "$SERVICE_NAME"

if systemctl is-active --quiet "$SERVICE_NAME"; then
    
    echo "$SERVICE_NAME service is now active and running."

else
    
    echo "ERROR: Failed to start $SERVICE_NAME service. Please check the logs for errors."
    exit 1
fi