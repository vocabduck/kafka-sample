#!/bin/bash

# Set API endpoints
AUTH_API_URL="https://auth.example.com/token"  # Replace with your token API
DOWNLOAD_API_URL="https://sit.referencecatalog.snapshots.icg.citigroup.net/snapshots/datastandards/globalorganizationcode/FullDump/latest"

# Client credentials (if needed)
CLIENT_ID="your_client_id"
CLIENT_SECRET="your_client_secret"
USERNAME="your_username"
PASSWORD="your_password"

# Step 1: Fetch Access Token
echo "Fetching access token..."
TOKEN_RESPONSE=$(curl -s -X POST "$AUTH_API_URL" \
    -H "Content-Type: application/json" \
    -d '{"client_id": "'"$CLIENT_ID"'", "client_secret": "'"$CLIENT_SECRET"'", "username": "'"$USERNAME"'", "password": "'"$PASSWORD"'", "grant_type": "password"}')

# Extract the token from the JSON response
ACCESS_TOKEN=$(echo "$TOKEN_RESPONSE" | jq -r '.access_token')

# Validate if token was retrieved
if [[ -z "$ACCESS_TOKEN" || "$ACCESS_TOKEN" == "null" ]]; then
    echo "Error: Failed to fetch access token"
    exit 1
fi

echo "Access token retrieved successfully."

# Step 2: Fetch Latest Snapshot Metadata
echo "Fetching latest snapshot metadata..."
RESPONSE_FILE="response.json"
curl -s -H "Authorization: Bearer $ACCESS_TOKEN" "$DOWNLOAD_API_URL" -o $RESPONSE_FILE

# Extract the latest file name from JSON
LATEST_FILE=$(jq -r '.results[0].name' < $RESPONSE_FILE)

if [[ -z "$LATEST_FILE" || "$LATEST_FILE" == "null" ]]; then
    echo "Error: Could not extract the file name."
    exit 1
fi

echo "Latest file: $LATEST_FILE"

# Step 3: Construct the full download URL
FILE_DOWNLOAD_URL="https://sit.referencecatalog.snapshots.icg.citigroup.net/snapshots/data/organizationcode/fd/$LATEST_FILE"

# Step 4: Download the file
if command -v aria2c &> /dev/null; then
    echo "Using aria2c for faster downloads..."
    aria2c -x 10 -s 10 -o "$LATEST_FILE" -H "Authorization: Bearer $ACCESS_TOKEN" "$FILE_DOWNLOAD_URL"
else
    echo "Using curl..."
    curl -o "$LATEST_FILE" -H "Authorization: Bearer $ACCESS_TOKEN" "$FILE_DOWNLOAD_URL"
fi

# Cleanup
rm -f $RESPONSE_FILE

echo "Download complete: $LATEST_FILE"
