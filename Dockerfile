FROM ubuntu:22.04

ENV container docker
ENV DEBIAN_FRONTEND noninteractive

COPY scripts/ /app/

RUN apt update && apt install -y \
    iproute2 iperf3 mptcpd \
    dnsmasq iftop ethtool psmisc \
    python3 python3-pip python3-yaml \
    netplan.io iptables && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    sed -i 's/\r$//' /app/*.sh && \
    chmod +x /app/*.sh

ENTRYPOINT ["/app/mptcp-setup.sh"]