FROM ubuntu:22.04

RUN apt update && apt install -y \
    iproute2 iperf3 mptcpd \
    dnsmasq iftop ethtool \
    python3 python3-pip \
    netplan.io iptables python3-yaml && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY requirements.txt /app/
RUN pip3 install -r /app/requirements.txt

COPY scripts/auto-detector.py /app/
COPY scripts/mptcp-setup.sh /app/

RUN chmod +x /app/*.sh

ENTRYPOINT ["/app/mptcp-setup.sh"]