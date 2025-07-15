#!/bin/bash

# ==== INSTALL NODE EXPORTER ==================================================================================================================================================

sudo apt update
sudo apt install -y curl tar

# Fetch the latest version of the node exporter
LATEST=$(curl -s https://api.github.com/repos/prometheus/node_exporter/releases/latest | grep '"tag_name":' | cut -d '"' -f4 | sed 's/^v//')

# Install the latest version of the node exporter
wget https://github.com/prometheus/node_exporter/releases/download/v${LATEST}/node_exporter-${LATEST}.linux-amd64.tar.gz
tar -xvzf node_exporter-*.*-amd64.tar.gz
cd node_exporter-*.*-amd64

# Create a systemd service for the node_exporter
sudo useradd --no-create-home --shell /bin/false node_exporter &> /dev/null
sudo useradd --no-create-home --shell /bin/false node_exporter &> /dev/null
sudo chown -R node_exporter:node_exporter /opt/node_exporter 
sudo mkdir /opt/node_exporter
sudo mv node_exporter /opt/node_exporter/

sudo su -c 'echo """
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/opt/node_exporter/node_exporter

[Install]
WantedBy=default.target
""" > /etc/systemd/system/node_exporter.service'

# Enable and start the node_exporter
sudo systemctl daemon-reexec &> /dev/null
sudo systemctl daemon-reload &> /dev/null
sudo systemctl enable node_exporter &> /dev/null
sudo systemctl start node_exporter &> /dev/null

# ==== REFERENCES =============================================================================================================================================================

# https://prometheus.io/docs/guides/node-exporter/
# https://prometheus.io/download/#node_exporter
