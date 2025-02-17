#!/bin/bash

# Step 1: Authenticate and Retrieve Bearer Token
AUTH_RESPONSE=$(curl -s --data "username=ictr_179819&password=ictr_179819" \
                      --header "Authorization: Basic Y2xvdWQtYXBpOg==" \
                      -X POST "https://referencedatacloudauth.sit.icg.citigroup.net/auth/token?grant_type=password")

# Extract the access token from JSON response
ACCESS_TOKEN=$(echo "$AUTH_RESPONSE" | grep -o '"access_token":"[^"]*' | cut -d':' -f2 | tr -d '"')

# Check if access token is empty
if [[ -z "$ACCESS_TOKEN" ]]; then
    echo "Error: Authentication failed. Unable to retrieve token."
    exit 1
fi

echo "Authentication successful. Token retrieved."

# Step 2: Get Latest Snapshot File Info
FILE_INFO=$(curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
                   -X GET "https://sit.referencecatalog.snapshots.icg.citigroup.net/snapshots/datastandards/globalorganizationcode/FullDump/latest")

# Extract filename from JSON response
FILENAME=$(echo "$FILE_INFO" | grep -o '"name":"[^"]*' | cut -d':' -f2 | tr -d '"')

# Check if filename is empty
if [[ -z "$FILENAME" ]]; then
    echo "Error: Unable to retrieve filename from API response."
    exit 1
fi

echo "Latest file found: $FILENAME"

# Step 3: Download the File
DOWNLOAD_URL="https://sit.referencecatalog.snapshots.icg.citigroup.net/snapshots/data/organizationcode/fd/$FILENAME"
curl -o "$FILENAME" -H "Authorization: Bearer $ACCESS_TOKEN" -X GET "$DOWNLOAD_URL"

# Check if download was successful
if [[ $? -eq 0 ]]; then
    echo "Download completed: $FILENAME"
else
    echo "Error: File download failed."
    exit 1
fi
