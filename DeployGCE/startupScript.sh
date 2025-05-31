#!/bin/bash

sudo curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
sudo bash add-google-cloud-ops-agent-repo.sh --also-install
sudo systemctl start google-cloud-ops-agent"*"

sudo apt -y install apache2
sudo apt -y update

sudo apt -y install git
sudo git clone https://github.com/JonmarCorpuz/SymmEncrypt.git
sudo mv SymmEncrypt/ /var/www/html
sudo sed -i 's|/var/www/html|/var/www/html/SymmEncrypt/Main|g' /etc/apache2/sites-available/000-default.conf 

sudo systemctl restart apache2
