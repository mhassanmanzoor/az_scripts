#!/bin/bash

# Set the resource group name and output file
RESOURCE_GROUP="Embedded-DevPartnerLink"
OUTPUT_FILE="powerbi_tls_versions.csv"

# Add headers to the CSV file
echo "Power BI Workspace Name,TLS Version" > $OUTPUT_FILE

# Function to get TLS version (dummy example, as TLS is generally not specified in Power BI settings)
get_tls_version() {
  # Placeholder: Power BI does not expose TLS versions through the API directly.
  # You might need to assume a default value.
  echo "TLS 1.2 (Default)"
}

# Get the list of Power BI workspaces in the resource group
# Note: You may need to use Azure REST API or Power BI API to get this list.
# Here, we're using a placeholder as there is no direct Azure CLI command for this.
WORKSPACES=("Workspace1" "Workspace2") # Replace this with actual workspace retrieval logic

if [ ${#WORKSPACES[@]} -eq 0 ]; then
  echo "No Power BI workspaces found in the resource group: $RESOURCE_GROUP"
  exit 1
fi

# Loop through each Power BI workspace and fetch the TLS version
for WORKSPACE in "${WORKSPACES[@]}"; do
  TLS_VERSION=$(get_tls_version) # Call the function to get TLS version

  # Output Workspace Name and TLS Version to CSV
  echo "$WORKSPACE,$TLS_VERSION" >> $OUTPUT_FILE
done

echo "TLS versions for Power BI workspaces have been saved to $OUTPUT_FILE"

