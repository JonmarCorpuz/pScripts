#!/bin/bash

####################################### STATIC VARIABLES ########################################

# Text Color
WHITE="\033[0m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
GREEN="\033[0;32m"

# Infinte Loop
ALWAYS_TRUE=true

######################################### REQUIREMENTS ##########################################

# Check if the user executed the script correctly
while getopts ":a:" opt; do
    case $opt in
        a) action="$OPTARG"
        ;;
        \?) echo -e "${RED}[ERROR 1]${WHITE} Usage: ./deploy.sh -a {apply|destroy}" && echo "" &&  exit 1
        ;;
        :) echo -e "${RED}[ERROR 2]${WHITE} Usage: ./deploy.sh -a {apply|destroy}" && echo "" && exit 1
        ;;
    esac
done

# Check if the user provided only the required values when executing the script
if [ $OPTIND -ne 3 ]; 
then
    echo -e "${RED}[ERROR 3]${WHITE} Usage: ./deploy.sh -a {apply|destroy}" && echo "" &&  exit 1
fi

if [[ ${2,,} == "apply" ]] || [[ ${2,,} == "destroy" ]];
then 
    echo ""
else
    echo -e "${RED}[ERROR 4]${WHITE} Usage: ./deploy.sh -a {apply|destroy}" && echo "" &&  exit 1
fi

# ==== GATHER USER INPUT ================================================================================================================
while [[ $ALWAYS_TRUE=true ]];
do 

    read -p "$(echo -e ${YELLOW}[REQUIRED]${WHITE} Please enter the project ID of the project where you want to deploy the resources in:) " ProjectID


    if ! gcloud projects describe $ProjectID &> /dev/null;
    then 
        echo "" && echo -e "${RED}[ERROR 1]${WHITE} A project with the ${ProjectID} project ID doesn't exists within your organization or you don't have access to it." && echo ""
    else
        break
    fi 

done 

while [[ $ALWAYS_TRUE=true ]];
do 

    read -p "$(echo -e ${YELLOW}[REQUIRED]${WHITE} Please enter the region where you want to host your instance group:) " InstanceGroupRegion

    if ! gcloud compute regions describe $InstanceGroupRegion --project $ProjectID &> /dev/null;
    then
        echo "" && echo -e "${RED}[ERROR 1]${WHITE} ${InstanceGroupRegion} couldn't be found. Please provide a valid region." && echo ""
    else
        break 
    fi 

done 

while [[ $ALWAYS_TRUE=true ]];
do 

    read -p "$(echo -e ${YELLOW}[REQUIRED]${WHITE} Please enter the machine type you want the instances in your instance group to have:) " MachineType

    if ! gcloud compute machine-types describe $MachineType --project $ProjectID --zone "${InstanceGroupRegion}-a" &> /dev/null;
    then
        echo "" && echo -e "${RED}[ERROR 1]${WHITE} ${MachineType} couldn't be found. Please provide a valid machine type." && echo ""
    else
        break
    fi 

done

while [[ $ALWAYS_TRUE=true ]];
do 

    read -p "$(echo -e ${YELLOW}[REQUIRED]${WHITE} Please enter the minimum of instances that you want your instance group to always have running:) " MinimumInstances

 if [[ $MinimumInstances -lt 1 ]];
    then
        echo "" && echo -e "${RED}[ERROR 1]${WHITE} Please enter a number that's equal to or greater than 1." && echo ""
    else
        break
    fi 

done 

while [[ $ALWAYS_TRUE=true ]];
do 

    read -p "$(echo -e ${YELLOW}[REQUIRED]${WHITE} Please enter the maximum number of instances that you want your instance group to scale up to:) " MaximumInstances

    if [[ $MaximumInstances -le $MinimumInstances ]];
    then
        echo "" && echo -e "${RED}[ERROR 1]${WHITE} Please enter a number that's greater than ${MinimumInstances}." && echo ""
    else
        break
    fi 

done 

# ==== INSERT USER INPUT ================================================================================================================

#
sed -i 's/PROJECT_ID/'"$ProjectID"'/g' ./tests/setup/main.tf
sed -i 's/PROJECT_ID/'"$ProjectID"'/g' ./main.tf

sed -i 's/PROJECT_REGION/'"$InstanceGroupRegion"'/g' ./main.tf
sed -i 's/MACHINE_TYPE/'"$MachineType"'/g' ./main.tf
sed -i 's/MINIMUM_INSTANCES/'"$MinimumInstances"'/g' ./main.tf
sed -i 's/MAXIMUM_INSTANCES/'"$MaximumInstances"'/g' ./main.tf

# ==== TERRAFORM ========================================================================================================================

terraform init

echo "" && echo -e "${GREEN}[SUCCESS]${WHITE} Initialized."
echo "" && echo -e "${YELLOW}[ONGOING]${WHITE} Validating keys." && echo ""

if terraform test;
then

    echo "" && echo -e "${GREEN}[SUCCESS]${WHITE} Keys are valid." && echo ""

    if [[ ${2,,} == "apply" ]];
    then

        #
        terraform apply --auto-approve
    else

        #
        terraform destroy --auto-approve
        rm -r .terraform/*
    fi

    #
    echo "" && echo -e "${GREEN}[SUCCESS]${WHITE} Yay it worked!" && exit 0

else

    #
    sed -i 's/'"$ProjectID"'/PROJECT_ID/g' ./tests/setup/main.tf
    
    echo "" && echo -e "${RED}[ERROR 5]${WHITE} Terraform test failed." && echo "" && exit 1
fi 
