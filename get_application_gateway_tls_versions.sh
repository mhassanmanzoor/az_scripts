#!/bin/bash

# Set the resource group name and output file
RESOURCE_GROUP="POD04-PRD-FRM-RG"
OUTPUT_FILE="application_gateway_tls_versions.csv"

# Add headers to the CSV file
echo "Application Gateway Name,TLS Version" > $OUTPUT_FILE

# Get the list of Application Gateway resources in the resource group
APP_GATEWAYS=$(az network application-gateway list --resource-group "$RESOURCE_GROUP" --query "[].name" -o tsv)

if [ -z "$APP_GATEWAYS" ]; then
  echo "No Application Gateways found in the resource group: $RESOURCE_GROUP"
  exit 1
fi

# Loop through each Application Gateway and fetch the TLS version
for APP_GATEWAY in $APP_GATEWAYS; do
  # Query the TLS version for each Application Gateway
  TLS_VERSION=$(az network application-gateway show --name "$APP_GATEWAY" --resource-group "$RESOURCE_GROUP" --query "sslPolicy.minProtocolVersion" -o tsv)

  # If TLS Version is not explicitly set, assume default is TLS 1.2
  if [ -z "$TLS_VERSION" ]; then
    TLS_VERSION="TLS 1.2 (Default)"
  fi

  # Output Application Gateway Name and TLS Version to CSV
  echo "$APP_GATEWAY,$TLS_VERSION" >> $OUTPUT_FILE
done

echo "TLS versions for Application Gateways have been saved to $OUTPUT_FILE"

