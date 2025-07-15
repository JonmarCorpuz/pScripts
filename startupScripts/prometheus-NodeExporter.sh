#!/bin/bash

# ==== INSTALL NODE EXPORTER ==================================================================================================================================================

wget https://github.com/prometheus/node_exporter/releases/download/v*/node_exporter-*.*-amd64.tar.gz
tar xvfz node_exporter-*.*-amd64.tar.gz
cd node_exporter-*.*-amd64
./node_exporter

# ==== REFERENCES =============================================================================================================================================================

# https://prometheus.io/docs/guides/node-exporter/
# https://prometheus.io/download/#node_exporter
