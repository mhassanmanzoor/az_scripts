# Network Access Validation Scripts for Azure Resources: Storage Accounts and Cosmos DB
- A script to check network access rules for all storage accounts in a specified Azure Resource Group, identifying if any are exposed to the public network.
```
#!/bin/bash

## Check if Resource Group name is provided as an argument
#if [ -z "$1" ]; then
#    echo "Usage: $0 <resource-group-name>"
#    exit 1
#fi

## Get the Resource Group name from the first argument
#RESOURCE_GROUP=$1

# Resource Group name
RESOURCE_GROUP="RG_NAME"

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
```

- A script to check network access rules for both Azure storage and Cosmos DB accounts in a specified Resource Group, identifying any that are exposed to the public network.
```
#!/bin/bash

# Resource Group name
RESOURCE_GROUP="RG_NAME"

# Function to check network rules for storage accounts

## For each storage account, the script fetches the network rules and checks the defaultAction (either "Allow" or "Deny"). If a storage account has no network rule or has "defaultAction": "Allow", it might be exposed to the external network.

check_storage_account() {
    echo "Fetching storage accounts in Resource Group: $RESOURCE_GROUP..."
    storage_accounts=$(az storage account list --resource-group "$RESOURCE_GROUP" --query '[].{name:name}' -o json)

    if [ "$(echo $storage_accounts | jq length)" -eq 0 ]; then
        echo "No storage accounts found in Resource Group: $RESOURCE_GROUP"
        return
    fi

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
    echo "Storage account network check completed."
}

# Function to check network rules for Cosmos DB accounts

## Cosmos DB uses Virtual Network (VNet) rules to restrict network access. If a Cosmos DB account allows access from "All Networks," it is exposed to the public.

check_cosmos_db() {
    echo "Fetching Cosmos DB accounts in Resource Group: $RESOURCE_GROUP..."
    cosmos_db_accounts=$(az cosmosdb list --resource-group "$RESOURCE_GROUP" --query '[].{name:name}' -o json)

    if [ "$(echo $cosmos_db_accounts | jq length)" -eq 0 ]; then
        echo "No Cosmos DB accounts found in Resource Group: $RESOURCE_GROUP"
        return
    fi

    echo "Checking network access for each Cosmos DB account in Resource Group: $RESOURCE_GROUP..."
    echo

    for account in $(echo "${cosmos_db_accounts}" | jq -r '.[] | @base64'); do
        _jq() {
            echo "${account}" | base64 --decode | jq -r "${1}"
        }

        account_name=$(_jq '.name')

        # Get the network rule settings for the current Cosmos DB account
        network_rules=$(az cosmosdb show --name "$account_name" --resource-group "$RESOURCE_GROUP" --query "virtualNetworkRules" -o json)

        if [ "$(echo "$network_rules" | jq length)" -eq 0 ]; then
            echo "Cosmos DB Account: $account_name is EXPOSED to the public network (no virtual network rules)."
        else
            echo "Cosmos DB Account: $account_name is secured with Virtual Network rules."
        fi
    done
    echo "Cosmos DB account network check completed."
}

# Main script execution
echo "Starting network check for Resource Group: $RESOURCE_GROUP..."

# Check storage accounts
check_storage_account

# Check Cosmos DB accounts
check_cosmos_db

echo "Network check completed for Resource Group: $RESOURCE_GROUP."
```
- A script that checks network access rules for Azure storage and Cosmos DB accounts in a specified Resource Group, logging the exposure status (secured or exposed) to a CSV file for further analysis.

```
#!/bin/bash

# Resource Group name
RESOURCE_GROUP="RG_NAME"

# Output CSV file
OUTPUT_CSV="network_check_results_$RESOURCE_GROUP.csv"

# Function to check network rules for storage accounts
check_storage_account() {
    echo "Fetching storage accounts in Resource Group: $RESOURCE_GROUP..."
    storage_accounts=$(az storage account list --resource-group "$RESOURCE_GROUP" --query '[].{name:name}' -o json)

    if [ "$(echo $storage_accounts | jq length)" -eq 0 ]; then
        echo "No storage accounts found in Resource Group: $RESOURCE_GROUP"
        return
    fi

    # Write storage account section header to CSV
    echo "Storage Accounts Network Check in $RESOURCE_GROUP" >> "$OUTPUT_CSV"
    echo "Account Type,Account Name,Exposure Status" >> "$OUTPUT_CSV"

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
            echo "Storage Account,$account_name,EXPOSED" >> "$OUTPUT_CSV"
        else
            echo "Storage Account: $account_name is secured (default action: Deny)."
            echo "Storage Account,$account_name,SECURED" >> "$OUTPUT_CSV"
        fi
    done
    echo "Storage account network check completed."
}

# Function to check network rules for Cosmos DB accounts
check_cosmos_db() {
    echo "Fetching Cosmos DB accounts in Resource Group: $RESOURCE_GROUP..."
    cosmos_db_accounts=$(az cosmosdb list --resource-group "$RESOURCE_GROUP" --query '[].{name:name}' -o json)

    if [ "$(echo $cosmos_db_accounts | jq length)" -eq 0 ]; then
        echo "No Cosmos DB accounts found in Resource Group: $RESOURCE_GROUP"
        return
    fi

    # Write Cosmos DB section header to CSV
    echo "" >> "$OUTPUT_CSV"  # Blank line to separate sections
    echo "Cosmos DB Network Check in $RESOURCE_GROUP" >> "$OUTPUT_CSV"
    echo "Account Type,Account Name,Exposure Status" >> "$OUTPUT_CSV"

    echo "Checking network access for each Cosmos DB account in Resource Group: $RESOURCE_GROUP..."
    echo

    for account in $(echo "${cosmos_db_accounts}" | jq -r '.[] | @base64'); do
        _jq() {
            echo "${account}" | base64 --decode | jq -r "${1}"
        }

        account_name=$(_jq '.name')

        # Get the network rule settings for the current Cosmos DB account
        network_rules=$(az cosmosdb show --name "$account_name" --resource-group "$RESOURCE_GROUP" --query "virtualNetworkRules" -o json)

        if [ "$(echo "$network_rules" | jq length)" -eq 0 ]; then
            echo "Cosmos DB Account: $account_name is EXPOSED to the public network (no virtual network rules)."
            echo "Cosmos DB,$account_name,EXPOSED" >> "$OUTPUT_CSV"
        else
            echo "Cosmos DB Account: $account_name is secured with Virtual Network rules."
            echo "Cosmos DB,$account_name,SECURED" >> "$OUTPUT_CSV"
        fi
    done
    echo "Cosmos DB account network check completed."
}

# Main script execution
echo "Starting network check for Resource Group: $RESOURCE_GROUP..."

# Create or overwrite the output CSV file and add headers
#echo "Account Type,Account Name,Exposure Status" > "$OUTPUT_CSV"

# Check storage accounts
check_storage_account

# Check Cosmos DB accounts
check_cosmos_db

echo "Network check completed for Resource Group: $RESOURCE_GROUP."
echo "Results saved to $OUTPUT_CSV."
```

