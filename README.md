# Network Binder

Bind multiple internet connection endpoints into single one using the Multipath TCP (mptcp).

## Project Structure

```
/root/
├── docker-compose.yml
├── config/
│   ├── netplan/
│   │   └── 01-netcfg.yaml  # Will be generated
│   ├── notifications.yaml
│   └── benchmarks.yaml
├── scripts/
│   ├── netplan_optimizer.py  # Main logic
│   └── entrypoint.sh
├── Dockerfile
└── README.md
```

