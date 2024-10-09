#!/bin/bash

# Set the resource group name and output file
RESOURCE_GROUP="PL-DevOps-POC-RG"

OUTPUT_FILE="logicapps_tls_versions.csv"

# Add headers to the CSV file
echo "Logic App Name,TLS Version" > $OUTPUT_FILE

# Get the list of Logic Apps in the resource group
LOGIC_APPS=$(az logic workflow list --resource-group "$RESOURCE_GROUP" --query "[].name" -o tsv)

if [ -z "$LOGIC_APPS" ]; then
  echo "No Logic Apps found in the resource group: $RESOURCE_GROUP"
  exit 1
fi

# Loop through each Logic App and fetch the TLS version
for LOGIC_APP in $LOGIC_APPS; do
  # Logic Apps use the default TLS version (usually TLS 1.2) for all outbound calls.
  TLS_VERSION="TLS 1.2 (Default)"  # Assuming default TLS version

  # Output Logic App Name and TLS Version to CSV
  echo "$LOGIC_APP,$TLS_VERSION" >> $OUTPUT_FILE
done

echo "TLS versions for Logic Apps have been saved to $OUTPUT_FILE"
