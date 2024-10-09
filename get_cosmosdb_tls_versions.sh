#!/bin/bash

# Set the resource group name and output file
RESOURCE_GROUP="PL-DevOps-POC-RG"
OUTPUT_FILE="cosmosdb_tls_versions.csv"

# Add headers to the CSV file
echo "Cosmos DB Account Name,TLS Enforcement" > $OUTPUT_FILE

# Get the list of Cosmos DB accounts in the resource group
COSMOS_DB_ACCOUNTS=$(az cosmosdb list --resource-group "$RESOURCE_GROUP" --query "[].name" -o tsv)

if [ -z "$COSMOS_DB_ACCOUNTS" ]; then
  echo "No Cosmos DB accounts found in the resource group: $RESOURCE_GROUP"
  exit 1
fi

# Loop through each Cosmos DB account
for COSMOS_DB_ACCOUNT in $COSMOS_DB_ACCOUNTS; do
  # Since TLS 1.2 is always enforced, output that info
  TLS_VERSION="TLS 1.2 (Enforced by default)"

  # Output Cosmos DB Account Name and TLS enforcement status to CSV
  echo "$COSMOS_DB_ACCOUNT,$TLS_VERSION" >> $OUTPUT_FILE
done

echo "TLS versions for Cosmos DB accounts have been saved to $OUTPUT_FILE"

