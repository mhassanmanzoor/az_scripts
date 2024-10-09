#!/bin/bash

# Set the resource group name and output file
RESOURCE_GROUP="PL-DevOps-POC-RG"
OUTPUT_FILE="storage_accounts_tls_versions.csv"

# Add headers to the CSV file
echo "Storage Account Name,TLS Version" > $OUTPUT_FILE

# Get the list of Storage Accounts in the resource group
STORAGE_ACCOUNTS=$(az storage account list --resource-group "$RESOURCE_GROUP" --query "[].name" -o tsv)

if [ -z "$STORAGE_ACCOUNTS" ]; then
  echo "No Storage Accounts found in the resource group: $RESOURCE_GROUP"
  exit 1
fi

# Loop through each Storage Account and fetch the TLS version
for STORAGE_ACCOUNT in $STORAGE_ACCOUNTS; do
  # Query the minimum TLS version for each Storage Account
  TLS_VERSION=$(az storage account show --name "$STORAGE_ACCOUNT" --resource-group "$RESOURCE_GROUP" --query "minimumTlsVersion" -o tsv)

  # If TLS Version is not explicitly set, assume default is TLS 1.2
  if [ -z "$TLS_VERSION" ]; then
    TLS_VERSION="TLS 1.2 (Default)"
  fi

  # Output Storage Account Name and TLS Version to CSV
  echo "$STORAGE_ACCOUNT,$TLS_VERSION" >> $OUTPUT_FILE
done

echo "TLS versions for Storage Accounts have been saved to $OUTPUT_FILE"

