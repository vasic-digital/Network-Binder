#!/usr/bin/env python3
import os
import yaml

def detect_interfaces():
    wans = []
    for dev in os.listdir('/sys/class/net'):
        if dev.startswith(('en', 'eth')) and dev != os.getenv('LAN_INTERFACE'):
            with open(f'/sys/class/net/{dev}/speed', 'r') as f:
                speed = int(f.read().strip())
            if speed >= 100:  # Only consider 100Mbps+ interfaces
                wans.append(dev)
    return sorted(wans)

if __name__ == "__main__":
    wans = detect_interfaces()
    config = {
        'network': {
            'version': 2,
            'renderer': 'networkd',
            'ethernets': {
                wan: {
                    'dhcp4': True,  # Use DHCP since ISPs use 192.168.0.X
                    'dhcp4-overrides': {
                        'route-metric': 100 + idx  # Different metric for each WAN
                    },
                    'optional': True
                } for idx, wan in enumerate(wans)
            }
        }
    }
    
    
    with open('/etc/netplan/50-cloud-init.yaml', 'w') as f:
        yaml.dump(config, f)
