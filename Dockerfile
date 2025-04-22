FROM ubuntu:22.04

RUN apt update && apt install -y \
    iproute2 iperf3 mptcpd \
    dnsmasq iftop ethtool \
    python3 python3-pip

COPY scripts/auto-detector.py /app/
COPY scripts/mptcp-setup.sh /app/

RUN chmod +x /app/*.sh

ENTRYPOINT ["/app/mptcp-setup.sh"]