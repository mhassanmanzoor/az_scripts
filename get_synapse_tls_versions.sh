#!/bin/bash

# Set the resource group name and output file
RESOURCE_GROUP="POD02-DEV-FRM-RG"
OUTPUT_FILE="synapse_tls_versions.csv"

# Add headers to the CSV file
echo "Synapse Workspace Name,TLS Version" > $OUTPUT_FILE

# Get the list of Synapse Analytics workspaces in the resource group
SYNAPSE_WORKSPACES=$(az synapse workspace list --resource-group "$RESOURCE_GROUP" --query "[].name" -o tsv)

if [ -z "$SYNAPSE_WORKSPACES" ]; then
  echo "No Synapse Workspaces found in the resource group: $RESOURCE_GROUP"
  exit 1
fi

# Loop through each Synapse workspace and fetch the TLS version
for SYNAPSE_WORKSPACE in $SYNAPSE_WORKSPACES; do
  # Query the minimal TLS version for each Synapse workspace
  TLS_VERSION=$(az synapse workspace show --name "$SYNAPSE_WORKSPACE" --resource-group "$RESOURCE_GROUP" --query "connectivityEndpoints.sql" -o tsv)

  # If TLS Version is not explicitly set or found, assume default is TLS 1.2
  if [ -z "$TLS_VERSION" ]; then
    TLS_VERSION="TLS 1.2 (Default)"
  fi

  # Output Synapse Workspace Name and TLS Version to CSV
  echo "$SYNAPSE_WORKSPACE,$TLS_VERSION" >> $OUTPUT_FILE
done

echo "TLS versions for Synapse Workspaces have been saved to $OUTPUT_FILE"

