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
                    'dhcp4': False,
                    'addresses': [f'192.168.{idx+1}.100/24'],
                    'routes': [{'to': '0.0.0.0/0', 'via': f'192.168.{idx+1}.1'}]
                } for idx, wan in enumerate(wans)
            }
        }
    }
    
    # TODO: Uncomment when ready
    # with open('/etc/netplan/01-mptcp.yaml', 'w') as f:
    with open('01-mptcp.yaml', 'w') as f:
        yaml.dump(config, f)
