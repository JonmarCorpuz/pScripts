#!/bin/bash

#### STATIC VARIABLES ###########################################################################

# Text Color
WHITE="\033[0m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
GREEN="\033[0;32m"

# Infinte Loop
ALWAYS_TRUE=true

#### REQUIREMENTS ###############################################################################

echo '''
         _               _             _             _      _                  _            _                   _      
        /\ \           /\ \           _\ \          /\ \   /\_\               /\ \         / /\                /\ \    
       /  \ \         /  \ \         /\__ \        /  \ \ / / /         _    /  \ \____   / /  \              /  \ \   
      / /\ \_\       / /\ \ \       / /_ \_\      / /\ \ \\ \ \__      /\_\ / /\ \_____\ / / /\ \            / /\ \ \  
     / / /\/_/      / / /\ \ \     / / /\/_/     / / /\ \ \\ \___\    / / // / /\/___  // / /\ \ \          / / /\ \_\ 
    / / / ______   / / /  \ \_\   / / /         / / /  \ \_\\__  /   / / // / /   / / // / /  \ \ \        / / /_/ / / 
   / / / /\_____\ / / /    \/_/  / / /         / / /   / / // / /   / / // / /   / / // / /___/ /\ \      / / /__\/ /  
  / / /  \/____ // / /          / / / ____    / / /   / / // / /   / / // / /   / / // / /_____/ /\ \    / / /_____/   
 / / /_____/ / // / /________  / /_/_/ ___/\ / / /___/ / // / /___/ / / \ \ \__/ / // /_________/\ \ \  / / /          
/ / /______\/ // / /_________\/_______/\__\// / /____\/ // / /____\/ /   \ \___\/ // / /_       __\ \_\/ / /           
\/___________/ \/____________/\_______\/    \/_________/ \/_________/     \/_____/ \_\___\     /____/_/\/_/                                                                                                                                  
'''
echo -e "${YELLOW}[DISCLAIMER]${WHITE} gCloudAP (Google Cloud Artifact Push) was created for testing purposes and should only be used in a testing environment."
echo -e "${YELLOW}[REQUIRED]${WHITE} Please ensure that you have ${YELLOW}docker${WHITE} and ${YELLOW}gcloud-cli${WHITE} installed and properly configured." && echo "" 

# Verify if the user executed the script correctly
while getopts ":p:" opt; do
    case $opt in
        f) file="$OPTARG"
        ;;
        \?) echo -e "${RED}[ERROR 1]${WHITE} Usage: ./gCloudAP.sh -p <PROJECT_ID>$" && echo "" &&  exit 1
        ;;
        :) echo -e "${RED}[ERROR 2]${WHITE} Usage: ./gCloudAP.sh -p <PROJECT_ID>." && echo "" && exit 1
        ;;
    esac
done

# Verify if the user provided only the required values when executing the script
if [ $OPTIND -eq 1 ]; 
then
    echo -e "${RED}[ERROR 3]${WHITE} Usage: ./gCloudAP.sh -p <PROJECT_ID>" && echo "" &&  exit 1
fi

# Verify if gcloud-cli is installed
if ! gcloud --version &> /dev/null; 
then
    echo -e "${RED}[GREEN]${WHITE} Please install the Google Cloud CLI" && echo ""
    exit 1
#    echo -e "${RED}[ERROR 3]${WHITE} Installing gcloud-cli" && echo ""
#    sudo apt -y update
#    sudo apt -y install apt-transport-https ca-certificates gnupg curl
#    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
#    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
#    sudo apt -y update && sudo apt -y install google-cloud-cli
#    echo -e "${RED}[GREEN]${WHITE} gcloud-cli installed successfully" && echo ""
fi

# Verify if the user is authenticated to Google Cloud
if ! gcloud projects describe $2 &> /dev/null;
then
    echo -e "${RED}[ERROR 3]${WHITE} Please authenticate to Google Cloud" && echo ""
    exit 1
fi

#### GATHER USER INPUT ##########################################################################

# Prompt the user for the full absolute path of their Dockerfile 
while [[ $ALWAYS_TRUE=true ]];
do
    read -p "$(echo -e ${YELLOW}[REQUIRED]${WHITE} Please enter the full absolute path of your Dockerfile:) " DockerfileLocation
    
    if cat $DockerfileLocation &> /dev/null; 
    then
        break
    else
        echo "" && echo -e "${RED}[ERROR 8]${WHITE} No Dockerfile was found at $DockerfileLocation. Please make sure you typed the full absolute path correctly." && echo ""
    fi
done

# Prompt the user for the name they'd like to give their Docker image (Must be in all lowercaps)
while [[ $ALWAYS_TRUE=true ]];
do
    read -p "$(echo -e ${YELLOW}[REQUIRED]${WHITE} Please enter the name you would like to give your image:) " ImageName

    if [[ $ImageName =~ [^a-zA-Z\d\s:] ]] || [[ $ImageName =~ [A-Z] ]] || [[ -z $ImageName ]];
    then
        echo "" && echo -e "${RED}[ERROR 8]${WHITE} Please ensure that the name contains only lowercase letters." && echo ""
    else
        break
    fi
done

# Prompt the user if they want to add a tag to their image
while [[ $ALWAYS_TRUE=true ]];
do
    read -p "$(echo -e ${YELLOW}[REQUIRED]${WHITE} Would you like to specify a tag to your image? [Y/N]) " TagOption

    if [[ $TagOption == "Y" ]] || [[ $TagOption == "N" ]]; 
    then
        break
    else
        echo "" && echo -e "${RED}[ERROR 8]${WHITE} Please type in either 'Y' or 'N'." && echo ""
    fi
done

# Prompt the user for the tag that they'd like to give their image if they said yes
if [[ $TagOption == "Y" ]];
then
    while [[ $ALWAYS_TRUE=true ]];
    do
        read -p "$(echo -e ${YELLOW}[REQUIRED]${WHITE} Please enter the tag you would like to give your image:) " TagName

        if [[ $ImageName =~ [^a-zA-Z\d\s:] ]] || [[ $ImageName =~ [A-Z] ]] || [[ -z $ImageName ]];
        then
            echo "" && echo -e "${RED}[ERROR 8]${WHITE} Please ensure that the tag name contains only lowercase letters." && echo ""
        else
            break
        fi
    done
fi

#### BUILD IMAGE ################################################################################

echo -e "${YELLOW}[ACTION]${WHITE} Buidling Docker image." && echo "" 

# Build the Docker image
if [[ $TagOption == "N" ]];
then
    docker build . -t $ImageName -f $DockerfileLocation
else
    docker build . -t $ImageName:$TagName -f $DockerfileLocation
fi

#### PUSH IMAGE TO ARTIFACT REGISTRY ############################################################

# Push the image to their project's Artifact Registry
if [[ $TagOption == "N" ]];
then
    echo -e "${YELLOW}[ACTION]${WHITE} Tagging the local image with the repository name." && echo "" 
    docker tag $ImageName gcr.io/$2/$ImageName 

    echo "" && echo -e "${YELLOW}[ACTION]${WHITE} Pushing the tagged image to Artifact Registry." && echo "" 
    docker push gcr.io/$2/$ImageName
else
    echo -e "${YELLOW}[ACTION]${WHITE} Tagging the local image with the repository name." && echo "" 
    docker tag $ImageName:$TagName gcr.io/$2/$ImageName

    echo "" && echo -e "${YELLOW}[ACTION]${WHITE} Pushing the tagged image to Artifact Registry." && echo "" 
    docker push gcr.io/$2/$ImageName
fi

echo "" && echo -e "${GREEN}[SUCCESS]${WHITE} gCloudAP has executed successfully." && echo ""
exit 0
