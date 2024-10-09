#!/bin/bash

# Suppress all Python warnings
export PYTHONWARNINGS="ignore"

# Set the resource group name and output file
RESOURCE_GROUP="pl-devops-poc-rg"
OUTPUT_FILE="function_app_tls_versions.csv"

# Add headers to the CSV file
echo "Function App Name,TLS Version" > $OUTPUT_FILE

# Get the list of Function Apps in the resource group
FUNCTION_APPS=$(az functionapp list --resource-group "$RESOURCE_GROUP" --query "[].name" -o tsv)

if [ -z "$FUNCTION_APPS" ]; then
  echo "No Function Apps found in the resource group: $RESOURCE_GROUP"
  exit 1
fi

# Loop through each Function App and fetch the TLS version
for FUNCTION_APP in $FUNCTION_APPS; do
  # Get the TLS version for the Function App
  TLS_VERSION=$(az functionapp show --name "$FUNCTION_APP" --resource-group "$RESOURCE_GROUP" --query "minTlsVersion" -o tsv)

  # If TLS Version is not explicitly set, assume default is TLS 1.2
  if [ -z "$TLS_VERSION" ]; then
    TLS_VERSION="TLS 1.2 (Default)"
  fi

  # Output Function App Name and TLS Version to CSV
  echo "$FUNCTION_APP,$TLS_VERSION" >> $OUTPUT_FILE
done

echo "TLS versions for Function Apps have been saved to $OUTPUT_FILE"

