#!/bin/bash

# Set the resource group name and output file
RESOURCE_GROUP="POD-COMMON-RG"
OUTPUT_FILE="mysql_tls_versions.csv"

# Add headers to the CSV file
echo "MySQL Server Name,TLS Version" > $OUTPUT_FILE

# Get the list of MySQL servers in the resource group
MYSQL_SERVERS=$(az mysql server list --resource-group "$RESOURCE_GROUP" --query "[].name" -o tsv)

if [ -z "$MYSQL_SERVERS" ]; then
  echo "No MySQL Servers found in the resource group: $RESOURCE_GROUP"
  exit 1
fi

# Loop through each MySQL server and fetch the minimal TLS version
for MYSQL_SERVER in $MYSQL_SERVERS; do
  # Query the minimal TLS version for each MySQL server
  TLS_VERSION=$(az mysql server show --name "$MYSQL_SERVER" --resource-group "$RESOURCE_GROUP" --query "minimalTlsVersion" -o tsv)

  # If TLS Version is not explicitly set, assume default is TLS 1.2
  if [ -z "$TLS_VERSION" ]; then
    TLS_VERSION="TLS 1.2 (Default)"
  fi

  # Output MySQL Server Name and TLS Version to CSV
  echo "$MYSQL_SERVER,$TLS_VERSION" >> $OUTPUT_FILE
done

echo "TLS versions for MySQL Servers have been saved to $OUTPUT_FILE"

