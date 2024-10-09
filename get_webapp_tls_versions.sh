#!/bin/bash

# Suppress CryptographyDeprecationWarning
export PYTHONWARNINGS="ignore"

# Set the resource group name and output file
RESOURCE_GROUP="pl-devops-poc-rg"
OUTPUT_FILE="webapp_tls_versions.csv"

# Add headers to the CSV file
echo "Web App Name,TLS Version" > $OUTPUT_FILE

# Get the list of Web Apps in the resource group
WEB_APPS=$(az webapp list --resource-group "$RESOURCE_GROUP" --query "[].name" -o tsv)

if [ -z "$WEB_APPS" ]; then
  echo "No Web Apps found in the resource group: $RESOURCE_GROUP"
  exit 1
fi

# Loop through each Web App and fetch the TLS version
for WEB_APP in $WEB_APPS; do
  # Get the TLS version for the Web App
  TLS_VERSION=$(az webapp show --name "$WEB_APP" --resource-group "$RESOURCE_GROUP" --query "minTlsVersion" -o tsv)

  # If TLS Version is not explicitly set, assume default is TLS 1.2
  if [ -z "$TLS_VERSION" ]; then
    TLS_VERSION="TLS 1.2 (Default)"
  fi

  # Output Web App Name and TLS Version to CSV
  echo "$WEB_APP,$TLS_VERSION" >> $OUTPUT_FILE
done

echo "TLS versions for Web Apps have been saved to $OUTPUT_FILE"

