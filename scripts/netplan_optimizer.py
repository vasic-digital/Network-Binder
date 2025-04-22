CONFIG = {
    'paths': {
        'config': '/etc/netplan/01-netcfg.yaml',
        'log': '/var/log/netplan_optimizer.log',
        'state': '/var/lib/netplan_optimizer/state.json'
    }
}

def load_configs():
    with open('/etc/netplan_optimizer/notifications.yaml') as f:
        NOTIFICATION_CONFIG.update(yaml.safe_load(f))
    with open('/etc/netplan_optimizer/benchmarks.yaml') as f:
        CONFIG['benchmark'].update(yaml.safe_load(f))

def benchmark_interface(interface):
    iperf_cmd = f"timeout {CONFIG['benchmark']['duration']} iperf3 -c {CONFIG['benchmark']['servers'][0]} -p 5202 -J -B {interface}"
    # ... rest of the function