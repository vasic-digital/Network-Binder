#!/bin/bash

sudo apt update
sudo apt install -y \
    git docker.io docker-compose \
    iptables-persistent netfilter-persistent \
    iftop ethtool

