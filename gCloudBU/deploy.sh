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

echo -e "${YELLOW}[DISCLAIMER]${WHITE} This script was created for testing purposes and should be used in a testing environment." && echo ""

# Check if the user executed the script correctly
while getopts ":p:" opt; do
    case $opt in
        f) file="$OPTARG"
        ;;
        \?) echo -e "${RED}[ERROR 1]${WHITE} Usage: ./deploy.sh -p <PROJECT_ID>$" && echo "" &&  exit 1
        ;;
        :) echo -e "${RED}[ERROR 2]${WHITE} Usage: ./deploy.sh -p <PROJECT_ID>." && echo "" && exit 1
        ;;
    esac
done

# Check if the user provided only the required values when executing the script
if [ $OPTIND -eq 1 ]; 
then
    echo -e "${RED}[ERROR 3]${WHITE} Usage: ./deploy.sh -p <PROJECT_ID>" && echo "" &&  exit 1
fi

#### SET PROJECT ################################################################################

# Set the project
if gcloud projects describe $2 &> /dev/null; 
then
    gcloud config set project $2
    echo -e "${GREEN}[SUCCESS]${WHITE} The project has been set."
else
    echo -e "${RED}[ERROR 4]${WHITE} The provided Project ID doesn't exist." && echo "" && exit 1
fi

#### CLOUD STORAGE ##############################################################################

# Specify which file they want to upload to Cloud Storage
while [[ $ALWAYS_TRUE=true ]];
do
    read -p "$(echo -e ${YELLOW}[REQUIRED]${WHITE} Please enter the full path of the file that you want to upload to Cloud Storage:) " FilePath
    if ! cat $FilePath > /dev/null;
    then
        echo "" && echo -e "${RED}[ERROR 5]${WHITE} Please ensure that ${FilePath} exists." && echo ""
    else
        break
    fi

done

# Specify the bucket that the user wants to upload their file to
while [[ $ALWAYS_TRUE=true ]];
do
    read -p "$(echo -e ${YELLOW}[REQUIRED]${WHITE} Please enter the name of the Bucket that you want to upload the file to:) " BucketName
    if ! gcloud storage buckets describe gs://$BucketName &> /dev/null;
    then

	echo "" && echo -e "${RED}[ERROR 8]${WHITE} The ${BucketName} was not found." && echo ""
        while [[ $ALWAYS_TRUE=true ]];
        do

            read -p "$(echo -e ${YELLOW}[REQUIRED]${WHITE} Would you like to create a new bucket? Y or N: ) " CreateBucket
	    if [[ ${CreateBucket,,} == "y" ]];
            then

                while [[ $ALWAYS_TRUE=true ]];
                do
                    # Create Bucket
                    read -p "$(echo -e ${YELLOW}[REQUIRED]${WHITE} Please enter the name you want to give your new bucket: ) " NewBucketName
	            if ! gcloud storage buckets create gs://$NewBucketName &> /dev/null;
	            then
                        echo "" && echo -e "${RED}[ERROR 8]${WHITE} ${NewBucketName} is unavailable. The bucket name needs to be globally unique" && echo ""
                    else
                        echo "" && echo -e "${GREEN}[SUCCESS]${WHITE} Bucket ${NewBucketName} was successfully created." && echo ""
                        break
                    fi

		done
                break

            elif [[ ${CreateBucket,,} == "n" ]];
	    then
	        break
            else
                echo "" && echo -e "${RED}[ERROR 8]${WHITE} Please only provide either 'Y' or 'N'." && echo ""
            fi

	done

    else
        break
    fi

done

# Upload the specified file to Cloud Storage
gsutil cp $FilePath gs://$BucketName/

# Exit successfully
echo "" && echo -e "${GREEN}[SUCCESS]${WHITE} Your file was successfully uploaded over at gs://$BucketName/." && exit 0
