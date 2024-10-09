#!/bin/bash

# Set the resource group name and output file
RESOURCE_GROUP="POD02-DEV-FRM-RG"

OUTPUT_FILE="appservice_tls_versions.csv"

# Add headers to the CSV file
echo "App Service Name,TLS Version" > $OUTPUT_FILE

# Get the list of App Service resources in the resource group
APP_SERVICES=$(az webapp list --resource-group "$RESOURCE_GROUP" --query "[].name" -o tsv)

if [ -z "$APP_SERVICES" ]; then
  echo "No App Services found in the resource group: $RESOURCE_GROUP"
  exit 1
fi

# Loop through each App Service and fetch the TLS version
for APP_SERVICE in $APP_SERVICES; do
  # Query the TLS version for each App Service
  TLS_VERSION=$(az webapp show --name "$APP_SERVICE" --resource-group "$RESOURCE_GROUP" --query "siteConfig.minTlsVersion" -o tsv)

  # If TLS Version is not explicitly set, assume default is TLS 1.2
  if [ -z "$TLS_VERSION" ]; then
    TLS_VERSION="TLS 1.2 (Default)"
  fi

  # Output App Service Name and TLS Version to CSV
  echo "$APP_SERVICE,$TLS_VERSION" >> $OUTPUT_FILE
done

echo "TLS versions for App Services have been saved to $OUTPUT_FILE"


