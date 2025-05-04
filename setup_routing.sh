#!/bin/bash

if [ -z "$LAN" ]; then

    echo "ERROR: No LAN defined"
    exit 1
fi

if [ -z "$ETH0" ]; then

    echo "ERROR: No ETH0 defined"
    exit 1
fi

if [ -z "$ETH1" ]; then

    echo "ERROR: No ETH1 defined"
    exit 1
fi

if [ -z "$ETH2" ]; then

    echo "ERROR: No ETH2 defined"
    exit 1
fi

# Exit on error and print commands
set -e
set -x

#!/bin/bash

# Interface definitions
ETH0="enxc84d4420851a"
ETH1="enxc84d44208982"
ETH2="enxc84d44293909"
LAN="eth3"

# Enable IP forwarding
echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward

# Install persistence package
sudo apt install -y iptables-persistent

# Flush existing rules
sudo iptables -F
sudo iptables -t nat -F

# NAT Rules
sudo iptables -t nat -A POSTROUTING -o $ETH0 -j MASQUERADE
sudo iptables -t nat -A POSTROUTING -o $ETH1 -j MASQUERADE
sudo iptables -t nat -A POSTROUTING -o $ETH2 -j MASQUERADE

# Forwarding Rules
sudo iptables -A FORWARD -i $LAN -o $ETH0 -m conntrack --ctstate NEW,ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A FORWARD -i $LAN -o $ETH1 -m conntrack --ctstate NEW,ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A FORWARD -i $LAN -o $ETH2 -m conntrack --ctstate NEW,ESTABLISHED,RELATED -j ACCEPT

sudo iptables -A FORWARD -i $ETH0 -o $LAN -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A FORWARD -i $ETH1 -o $LAN -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A FORWARD -i $ETH2 -o $LAN -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Save rules
sudo netfilter-persistent save

# Enable MPTCP requirements
sudo modprobe nf_conntrack
echo "nf_conntrack" | sudo tee -a /etc/modules

echo "Router setup complete!"

# Temporarely allow all communication throught the firewall
sudo iptables -P INPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -F

# Create custom routing tables (only if they don't exist)
grep -q "100 $ETH0" /etc/iproute2/rt_tables || echo "100 $ETH0" | sudo tee -a /etc/iproute2/rt_tables
grep -q "200 $ETH1" /etc/iproute2/rt_tables || echo "200 $ETH1" | sudo tee -a /etc/iproute2/rt_tables
grep -q "300 $ETH2" /etc/iproute2/rt_tables || echo "300 $ETH2" | sudo tee -a /etc/iproute2/rt_tables

# Function to safely add rules
add_rule() {
    
    local iface=$1
    local ip=$(ip -4 addr show "$iface" | grep -oP '(?<=inet\s)\d+(\.\d+){3}' || true)
    
    if [ -z "$ip" ]; then
    
        echo "Warning: No IPv4 address found on $iface"
        return 1
    fi
    
    # Check if rule exists before adding
    if ! ip rule show | grep -q "from $ip lookup $iface"; then
    
        sudo ip rule add from "$ip" table "$iface"
    fi
}

# Function to add default route
add_default_route() {
    
    local iface=$1
    local gw=$(ip route show dev "$iface" | awk '/default/ {print $3}' | head -n1)
    
    if [ -z "$gw" ]; then
    
        echo "Warning: No default gateway found for $iface"
        return 1
    fi
    
    # Check if route exists before adding
    if ! ip route show table "$iface" | grep -q "^default"; then
    
        sudo ip route add default via "$gw" table "$iface"
    fi
}

# Apply rules and routes
add_rule "$ETH0"
add_rule "$ETH1"
add_rule "$ETH2"

add_default_route "$ETH0"
add_default_route "$ETH1"
add_default_route "$ETH2"

# Enable MPTCP for these connections
sudo ip rule add from all lookup main suppress_prefixlength 0

echo "Multi-WAN routing setup complete"

ip rule show
ip route show table $ETH0
ip route show table $ETH1
ip route show table $ETH2