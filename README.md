# Network Binder

Bind multiple internet connection endpoints into single one using the Multipath TCP (mptcp).

## Project status

Currently **UNDER THE DEVELOPMENT**.

### TODO

- Replace / rebrand the `netplan-*` to `network-binder`.

## Project Structure

```
/root/
|
├── ...
├── docker-compose.yml
├── config/
│   ├── netplan/
│   │   └── 01-netcfg.yaml      # Will be generated
│   ├── notifications.yaml
│   └── benchmarks.yaml
├── scripts/
│   ├── netplan_optimizer.py    # Main logic
│   └── entrypoint.sh
├── Dockerfile
├── ...
├── LICENSE
├── README.md
└── README.pdf                  # Will be generated
```

## Deployment Workflow

1. **Build and Start**:
   ```bash
   docker-compose build
   docker-compose up -d
   ```

2. **Manual Trigger**:
   ```bash
   docker exec netplan-optimizer python netplan_optimizer.py
   ```

3. **View Logs**:
   ```bash
   docker logs -f netplan-optimizer
   ```