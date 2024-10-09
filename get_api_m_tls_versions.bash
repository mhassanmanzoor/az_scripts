#!/bin/bash


RESOURCE_GROUP="POD-COMMON-RG"
OUTPUT_FILE="apim_tls_versions.csv"

# Add headers to the CSV file
echo "APIM Name,TLS Version" > $OUTPUT_FILE

# Get the list of API Management (APIM) services in the resource group
APIM_SERVICES=$(az apim list --resource-group "$RESOURCE_GROUP" --query "[].name" -o tsv)

if [ -z "$APIM_SERVICES" ]; then
  echo "No API Management services found in the resource group: $RESOURCE_GROUP"
  exit 1
fi

# Loop through each APIM service and fetch the TLS version
for APIM_NAME in $APIM_SERVICES; do
  # Adjust this line with the correct query path based on your inspection
  TLS_VERSION=$(az apim show --name "$APIM_NAME" --resource-group "$RESOURCE_GROUP" --query "hostnameConfigurations[0].tlsVersion" -o tsv)

  # If TLS Version is not explicitly set, assume default is TLS 1.2
  if [ -z "$TLS_VERSION" ]; then
    TLS_VERSION="TLS 1.2 (Default)"
  fi

  # Output APIM Name and TLS Version to CSV
  echo "$APIM_NAME,$TLS_VERSION" >> $OUTPUT_FILE
done

echo "TLS versions have been saved to $OUTPUT_FILE"

