#!/bin/bash

# Set the resource group name and output file
RESOURCE_GROUP="PL-EUS-DEV-CUS-PORTAL"
OUTPUT_FILE="sql_tls_versions.csv"

# Add headers to the CSV file
echo "SQL Server Name,TLS Version" > $OUTPUT_FILE

# Get the list of SQL servers in the resource group
SQL_SERVERS=$(az sql server list --resource-group "$RESOURCE_GROUP" --query "[].name" -o tsv)

if [ -z "$SQL_SERVERS" ]; then
  echo "No SQL Servers found in the resource group: $RESOURCE_GROUP"
  exit 1
fi

# Loop through each SQL server and fetch the minimum TLS version
for SQL_SERVER in $SQL_SERVERS; do
  # Query the minimal TLS version for each SQL server
  TLS_VERSION=$(az sql server show --name "$SQL_SERVER" --resource-group "$RESOURCE_GROUP" --query "minimalTlsVersion" -o tsv)

  # If TLS Version is not explicitly set, assume default is TLS 1.2
  if [ -z "$TLS_VERSION" ]; then
    TLS_VERSION="TLS 1.2 (Default)"
  fi

  # Output SQL Server Name and TLS Version to CSV
  echo "$SQL_SERVER,$TLS_VERSION" >> $OUTPUT_FILE
done

echo "TLS versions for SQL Servers have been saved to $OUTPUT_FILE"

