#!/bin/bash

# ==== INSTALL OPS AGENT ======================================================================================================================================================

# Install the latest version 
curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
sudo bash add-google-cloud-ops-agent-repo.sh --also-install

# ==== REFERENCES =============================================================================================================================================================

# https://cloud.google.com/stackdriver/docs/solutions/agents/ops-agent/installation
