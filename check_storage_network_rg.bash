#!/bin/bash

## Check if Resource Group name is provided as an argument
#if [ -z "$1" ]; then
#    echo "Usage: $0 <resource-group-name>"
#    exit 1
#fi

## Get the Resource Group name from the first argument
#RESOURCE_GROUP=$1

# Resource Group name
RESOURCE_GROUP="PL-DevOps-POC-RG"

# Get a list of all storage accounts in the specified resource group
echo "Fetching storage accounts in Resource Group: $RESOURCE_GROUP..."
storage_accounts=$(az storage account list --resource-group "$RESOURCE_GROUP" --query '[].{name:name}' -o json)

if [ "$(echo $storage_accounts | jq length)" -eq 0 ]; then
    echo "No storage accounts found in Resource Group: $RESOURCE_GROUP"
    exit 0
fi

# Loop through each storage account to check the network access rules
echo "Checking network access for each storage account in Resource Group: $RESOURCE_GROUP..."
echo

for account in $(echo "${storage_accounts}" | jq -r '.[] | @base64'); do
    _jq() {
        echo "${account}" | base64 --decode | jq -r "${1}"
    }

    account_name=$(_jq '.name')

    # Get the network rule settings for the current storage account
    network_rules=$(az storage account show --name "$account_name" --resource-group "$RESOURCE_GROUP" --query "networkRuleSet" -o json)

    default_action=$(echo "$network_rules" | jq -r '.defaultAction')

    if [ "$default_action" == "Allow" ]; then
        echo "Storage Account: $account_name is EXPOSED to the public network (default action: Allow)."
    else
        echo "Storage Account: $account_name is secured (default action: Deny)."
    fi
done

echo
echo "Network check completed for Resource Group: $RESOURCE_GROUP."