FROM ubuntu:22.04

ENV container docker
ENV DEBIAN_FRONTEND noninteractive

RUN sed -i 's|http://.*archive.ubuntu.com|https://mirrors.ustc.edu.cn|g' /etc/apt/sources.list && \
    sed -i 's|http://.*security.ubuntu.com|https://mirrors.ustc.edu.cn|g' /etc/apt/sources.list

RUN apt-get update 

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    iproute2 iperf3 mptcpd \
    dnsmasq \              
    iftop ethtool \        
    psmisc \               
    python3 python3-pip python3-yaml \ 
    netplan.io \                      
    iptables-legacy && \              
    update-alternatives --set iptables /usr/sbin/iptables-legacy && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY scripts/ /app/

RUN sed -i 's/\r$//' /app/*.sh && \
    chmod +x /app/*.sh

ENTRYPOINT ["/app/mptcp-setup.sh"]