#!/bin/bash

# Set the resource group name and output file
RESOURCE_GROUP="PL-DevOps-POC-RG"
OUTPUT_FILE="keyvault_tls_versions.csv"

# Add headers to the CSV file
echo "Key Vault Name,TLS Version" > $OUTPUT_FILE

# Get the list of Key Vaults in the resource group
KEY_VAULTS=$(az keyvault list --resource-group "$RESOURCE_GROUP" --query "[].name" -o tsv)

if [ -z "$KEY_VAULTS" ]; then
  echo "No Key Vaults found in the resource group: $RESOURCE_GROUP"
  exit 1
fi

# Loop through each Key Vault and fetch the TLS version
for KEY_VAULT in $KEY_VAULTS; do
  # Query the minimal TLS version for each Key Vault
  TLS_VERSION=$(az keyvault show --name "$KEY_VAULT" --resource-group "$RESOURCE_GROUP" --query "properties.networkAcls.defaultAction" -o tsv)

  # If TLS Version is not explicitly set, assume default is TLS 1.2
  if [ -z "$TLS_VERSION" ]; then
    TLS_VERSION="TLS 1.2 (Default)"
  fi

  # Output Key Vault Name and TLS Version to CSV
  echo "$KEY_VAULT,$TLS_VERSION" >> $OUTPUT_FILE
done

echo "TLS versions for Key Vaults have been saved to $OUTPUT_FILE"

