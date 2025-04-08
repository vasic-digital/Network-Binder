FROM python:3.9-slim

# Install dependencies
RUN apt-get update && apt-get install -y \
    iproute2 \
    iperf3 \
    iputils-ping \
    net-tools \
    cron \
    && rm -rf /var/lib/apt/lists/*

# Install Python packages
RUN pip install --no-cache-dir \
    pyyaml \
    requests \
    twilio \
    python-dotenv

# Copy application
WORKDIR /app
COPY scripts/netplan_optimizer.py .
COPY scripts/entrypoint.sh .
COPY config/notifications.yaml /etc/netplan_optimizer/
COPY config/benchmarks.yaml /etc/netplan_optimizer/

RUN chmod +x entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]