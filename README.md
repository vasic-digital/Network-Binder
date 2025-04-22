# Network Binder

Bind multiple internet connection endpoints into single one using the Multipath TCP (mptcp).

A **production-ready MPTCP router** with:

✅ Automatic multi-WAN detection  
✅ Secure Docker integration  
✅ Optimized traffic bonding  
✅ Real-time monitoring  
✅ Self-healing firewall

## Project status

Currently **UNDER THE DEVELOPMENT**.

## Development environment

- Ubuntu Server 24.04.2 LTS

### TODOs

- None.

## Project structure

```bash
# /mptcp-router/
# ├── docker-compose.yml
# ├── config/
# │   ├── netplan/ (auto-generated)
# │   ├── firewall/
# │   │   └── rules.v4
# │   └── mptcp/
# │       └── mptcp.conf
# ├── scripts/
# │   ├── auto-detector.sh
# │   └── firewall-setup.sh
# └── README.md
```

