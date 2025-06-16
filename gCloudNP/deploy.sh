#!/bin/bash

# ==== VARIABLES ========================================================

# Text Color
WHITE="\033[0m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
GREEN="\033[0;32m"

csv_file="networks.csv"

# ==== MAIN BODY ========================================================
tail -n +2 "$csv_file" | while IFS=',' read -r currentProject currentNetwork || [ -n "$projectID" ];
do
    counter=1
    gcloud config set project $currentProject
        
    tail -n +2 "$csv_file" | while IFS=',' read -r projectID network || [ -n "$projectID" ];
    do
        echo -e "${YELLOW}[NOTICE]${WHITE}Peering $currentNetwork with $network in $projectID"
        gcloud compute networks peerings create pscripts-gcloudpn${counter} \
            --network=$currentNetwork \
            --peer-project=$projectID \
            --peer-network=$network \
            --import-custom-routes \
            --export-custom-routes \
            --import-subnet-routes-with-public-ip \
            --export-subnet-routes-with-public-ip
                
        ((counter++))
    done
done

exit 0