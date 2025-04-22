#!/bin/bash

sudo apt update
sudo apt install -y \
    iptables-persistent netfilter-persistent \
    iftop ethtool

docker-compose build
docker-compose up -d

docker logs mptcp-router