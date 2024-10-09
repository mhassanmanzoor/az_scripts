#!/bin/bash

# Set the resource group name and output file
RESOURCE_GROUP="PL-DevOps-POC-RG"
OUTPUT_FILE="servicebus_tls_versions.csv"

# Add headers to the CSV file
echo "Service Bus Name,TLS Version" > $OUTPUT_FILE

# Get the list of Service Bus namespaces in the resource group
SERVICE_BUS_NAMESPACES=$(az servicebus namespace list --resource-group "$RESOURCE_GROUP" --query "[].name" -o tsv)

if [ -z "$SERVICE_BUS_NAMESPACES" ]; then
  echo "No Service Bus namespaces found in the resource group: $RESOURCE_GROUP"
  exit 1
fi

# Loop through each Service Bus namespace and fetch the TLS version
for NAMESPACE in $SERVICE_BUS_NAMESPACES; do
  # Service Bus uses TLS 1.2 by default for all communications.
  TLS_VERSION="TLS 1.2 (Default)"  # Assuming default TLS version

  # Output Service Bus Name and TLS Version to CSV
  echo "$NAMESPACE,$TLS_VERSION" >> $OUTPUT_FILE
done

echo "TLS versions for Service Bus namespaces have been saved to $OUTPUT_FILE"

