#!/bin/bash

sudo apt update
sudo apt install -y \
    iptables-persistent netfilter-persistent \
    iftop ethtool

