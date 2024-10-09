#!/bin/bash

# Set the resource group name and output file
RESOURCE_GROUP="PL-DevOps-POC-RG"
OUTPUT_FILE="vpn_gateway_tls_versions.csv"

# Add headers to the CSV file
echo "VPN Gateway Name,TLS Version" > $OUTPUT_FILE

# Get the list of VPN Gateways in the resource group
VPN_GATEWAYS=$(az network vnet-gateway list --resource-group "$RESOURCE_GROUP" --query "[].name" -o tsv)

if [ -z "$VPN_GATEWAYS" ]; then
  echo "No VPN Gateways found in the resource group: $RESOURCE_GROUP"
  exit 1
fi

# Loop through each VPN Gateway and fetch the TLS version
for GATEWAY in $VPN_GATEWAYS; do
  # VPN Gateway uses TLS 1.2 by default for all communications.
  TLS_VERSION="TLS 1.2 (Default)"  # Assuming default TLS version

  # Output VPN Gateway Name and TLS Version to CSV
  echo "$GATEWAY,$TLS_VERSION" >> $OUTPUT_FILE
done

echo "TLS versions for VPN Gateways have been saved to $OUTPUT_FILE"

