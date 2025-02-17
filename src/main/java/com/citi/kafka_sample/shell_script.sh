#!/bin/bash

# API Endpoints
AUTH_URL="https://referencedatacloudauth.sit.icg.citigroup.net/auth/token?grant_type=password"
DOWNLOAD_URL="https://sit.referencecatalog.snapshots.icg.citigroup.net/snapshots/datastandards/globalorganizationcode/FullDump/latest"

# Credentials
USERNAME="ictr_179819"
PASSWORD="ictr_179819"
AUTH_HEADER="Basic Y2xvdWQtYXBpOg=="  # Update if needed

# Fetch authentication token
echo "Fetching authentication token..."
TOKEN_RESPONSE=$(curl -s -X POST "$AUTH_URL" \
    --data "username=$USERNAME&password=$PASSWORD" \
    --header "Authorization: $AUTH_HEADER" | tr -d '\n' | tr -d ' ')

# Debugging: Print Raw Response
echo "Raw Token Response: $TOKEN_RESPONSE"

# Check if response is empty
if [[ -z "$TOKEN_RESPONSE" ]]; then
    echo "Error: No response from authentication server."
    exit 1
fi

# Extract token using awk (instead of grep or sed)
ACCESS_TOKEN=$(echo "$TOKEN_RESPONSE" | awk -F'"' '{for(i=1;i<=NF;i++){if($i=="access_token"){print $(i+2)}}}')

# Check if token was received
if [[ -z "$ACCESS_TOKEN" || "$ACCESS_TOKEN" == "null" ]]; then
    echo "Failed to fetch authentication token. Response: $TOKEN_RESPONSE"
    exit 1
fi

echo "Token fetched successfully: $ACCESS_TOKEN"

# Set output filenames
OUTPUT_FILE="globalorganizationcode-latest.gz"
HEADER_FILE="globalorganizationcode-header.txt"

# Download file using the retrieved token
echo "Downloading file..."
curl -k -o "$OUTPUT_FILE" \
     -H "Authorization: Bearer $ACCESS_TOKEN" \
     -w "\nResponse code:%{http_code}" \
     --dump-header "$HEADER_FILE" \
     "$DOWNLOAD_URL"

# Verify download success
if [[ -f "$OUTPUT_FILE" ]]; then
    echo "Download complete: $OUTPUT_FILE"
else
    echo "Download failed."
    exit 1
fi
