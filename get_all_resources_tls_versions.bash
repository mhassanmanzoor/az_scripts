#!/bin/bash

# Suppress all Python warnings
export PYTHONWARNINGS="ignore"

# Set the resource groups
RESOURCE_GROUPS=("POD-COMMON-RG" "pl-devops-poc-rg" "POD04-PRD-FRM-RG" "PL-DevOps-POC-RG" "POD02-DEV-FRM-RG")

# Set the output file for combined results
OUTPUT_FILE="azure_resources_tls_versions_summary.csv"

# Add headers to the CSV file
echo "Resource Type,Resource Name,TLS Version" > $OUTPUT_FILE

# Function to get TLS version for Power BI workspaces (dummy example)
get_tls_version() {
  # Placeholder: Power BI does not expose TLS versions through the API directly.
  echo "TLS 1.2 (Default)"
}

# Loop through each resource group
for RESOURCE_GROUP in "${RESOURCE_GROUPS[@]}"; do
  echo "Processing resource group: $RESOURCE_GROUP"

  #### API Management
  APIM_SERVICES=$(az apim list --resource-group "$RESOURCE_GROUP" --query "[].name" -o tsv)
  if [ -z "$APIM_SERVICES" ]; then
    echo "No API Management services found in the resource group: $RESOURCE_GROUP"
  else
    for APIM_NAME in $APIM_SERVICES; do
      TLS_VERSION=$(az apim show --name "$APIM_NAME" --resource-group "$RESOURCE_GROUP" --query "hostnameConfigurations[0].tlsVersion" -o tsv)
      TLS_VERSION=${TLS_VERSION:-"TLS 1.2 (Default)"}
      echo "API Management,$APIM_NAME,$TLS_VERSION" >> $OUTPUT_FILE
    done
  fi

  #### Function Apps
  FUNCTION_APPS=$(az functionapp list --resource-group "$RESOURCE_GROUP" --query "[].name" -o tsv)
  if [ -z "$FUNCTION_APPS" ]; then
    echo "No Function Apps found in the resource group: $RESOURCE_GROUP"
  else
    for FUNCTION_APP in $FUNCTION_APPS; do
      TLS_VERSION=$(az functionapp show --name "$FUNCTION_APP" --resource-group "$RESOURCE_GROUP" --query "minTlsVersion" -o tsv)
      TLS_VERSION=${TLS_VERSION:-"TLS 1.2 (Default)"}
      echo "Function App,$FUNCTION_APP,$TLS_VERSION" >> $OUTPUT_FILE
    done
  fi

  #### Web Apps
  WEB_APPS=$(az webapp list --resource-group "$RESOURCE_GROUP" --query "[].name" -o tsv)
  if [ -z "$WEB_APPS" ]; then
    echo "No Web Apps found in the resource group: $RESOURCE_GROUP"
  else
    for WEB_APP in $WEB_APPS; do
      TLS_VERSION=$(az webapp show --name "$WEB_APP" --resource-group "$RESOURCE_GROUP" --query "minTlsVersion" -o tsv)
      TLS_VERSION=${TLS_VERSION:-"TLS 1.2 (Default)"}
      echo "Web App,$WEB_APP,$TLS_VERSION" >> $OUTPUT_FILE
    done
  fi

  #### Application Gateway
  APP_GATEWAYS=$(az network application-gateway list --resource-group "$RESOURCE_GROUP" --query "[].name" -o tsv)
  if [ -z "$APP_GATEWAYS" ]; then
    echo "No Application Gateways found in the resource group: $RESOURCE_GROUP"
  else
    for APP_GATEWAY in $APP_GATEWAYS; do
      TLS_VERSION=$(az network application-gateway show --name "$APP_GATEWAY" --resource-group "$RESOURCE_GROUP" --query "sslPolicy.minProtocolVersion" -o tsv)
      TLS_VERSION=${TLS_VERSION:-"TLS 1.2 (Default)"}
      echo "Application Gateway,$APP_GATEWAY,$TLS_VERSION" >> $OUTPUT_FILE
    done
  fi

  #### Azure Cosmos DB
  COSMOS_DB_ACCOUNTS=$(az cosmosdb list --resource-group "$RESOURCE_GROUP" --query "[].name" -o tsv)
  if [ -z "$COSMOS_DB_ACCOUNTS" ]; then
    echo "No Cosmos DB accounts found in the resource group: $RESOURCE_GROUP"
  else
    for COSMOS_DB_ACCOUNT in $COSMOS_DB_ACCOUNTS; do
      TLS_VERSION="TLS 1.2 (Enforced by default)"
      echo "Cosmos DB,$COSMOS_DB_ACCOUNT,$TLS_VERSION" >> $OUTPUT_FILE
    done
  fi

  #### Azure Database for MySQL
  MYSQL_SERVERS=$(az mysql server list --resource-group "$RESOURCE_GROUP" --query "[].name" -o tsv)
  if [ -z "$MYSQL_SERVERS" ]; then
    echo "No MySQL Servers found in the resource group: $RESOURCE_GROUP"
  else
    for MYSQL_SERVER in $MYSQL_SERVERS; do
      TLS_VERSION=$(az mysql server show --name "$MYSQL_SERVER" --resource-group "$RESOURCE_GROUP" --query "minimalTlsVersion" -o tsv)
      TLS_VERSION=${TLS_VERSION:-"TLS 1.2 (Default)"}
      echo "MySQL Server,$MYSQL_SERVER,$TLS_VERSION" >> $OUTPUT_FILE
    done
  fi

  #### Azure SQL
  SQL_SERVERS=$(az sql server list --resource-group "$RESOURCE_GROUP" --query "[].name" -o tsv)
  if [ -z "$SQL_SERVERS" ]; then
    echo "No SQL Servers found in the resource group: $RESOURCE_GROUP"
  else
    for SQL_SERVER in $SQL_SERVERS; do
      TLS_VERSION=$(az sql server show --name "$SQL_SERVER" --resource-group "$RESOURCE_GROUP" --query "minimalTlsVersion" -o tsv)
      TLS_VERSION=${TLS_VERSION:-"TLS 1.2 (Default)"}
      echo "SQL Server,$SQL_SERVER,$TLS_VERSION" >> $OUTPUT_FILE
    done
  fi

  #### Azure Synapse Analytics
  SYNAPSE_WORKSPACES=$(az synapse workspace list --resource-group "$RESOURCE_GROUP" --query "[].name" -o tsv)
  if [ -z "$SYNAPSE_WORKSPACES" ]; then
    echo "No Synapse Workspaces found in the resource group: $RESOURCE_GROUP"
  else
    for SYNAPSE_WORKSPACE in $SYNAPSE_WORKSPACES; do
      TLS_VERSION=$(az synapse workspace show --name "$SYNAPSE_WORKSPACE" --resource-group "$RESOURCE_GROUP" --query "connectivityEndpoints.sql" -o tsv)
      TLS_VERSION=${TLS_VERSION:-"TLS 1.2 (Default)"}
      echo "Synapse Workspace,$SYNAPSE_WORKSPACE,$TLS_VERSION" >> $OUTPUT_FILE
    done
  fi

  #### Key Vault
  KEY_VAULTS=$(az keyvault list --resource-group "$RESOURCE_GROUP" --query "[].name" -o tsv)
  if [ -z "$KEY_VAULTS" ]; then
    echo "No Key Vaults found in the resource group: $RESOURCE_GROUP"
  else
    for KEY_VAULT in $KEY_VAULTS; do
      TLS_VERSION=$(az keyvault show --name "$KEY_VAULT" --resource-group "$RESOURCE_GROUP" --query "properties.networkAcls.defaultAction" -o tsv)
      TLS_VERSION=${TLS_VERSION:-"TLS 1.2 (Default)"}
      echo "Key Vault,$KEY_VAULT,$TLS_VERSION" >> $OUTPUT_FILE
    done
  fi

  #### Logic Apps
  LOGIC_APPS=$(az logic workflow list --resource-group "$RESOURCE_GROUP" --query "[].name" -o tsv)
  if [ -z "$LOGIC_APPS" ]; then
    echo "No Logic Apps found in the resource group: $RESOURCE_GROUP"
  else
    for LOGIC_APP in $LOGIC_APPS; do
      TLS_VERSION="TLS 1.2 (Default)"  # Assuming default TLS version
      echo "Logic App,$LOGIC_APP,$TLS_VERSION" >> $OUTPUT_FILE
    done
  fi

  #### Power BI Workspaces
  WORKSPACES=("Workspace1" "Workspace2") # Replace this with actual workspace retrieval logic
  if [ ${#WORKSPACES[@]} -eq 0 ]; then
    echo "No Power BI workspaces found in the resource group: $RESOURCE_GROUP"
  else
    for WORKSPACE in "${WORKSPACES[@]}"; do
      TLS_VERSION=$(get_tls_version) # Call the function to get TLS version
      echo "Power BI Workspace,$WORKSPACE,$TLS_VERSION" >> $OUTPUT_FILE
    done
  fi

  #### Service Bus
  SERVICE_BUS_NAMESPACES=$(az servicebus namespace list --resource-group "$RESOURCE_GROUP" --query "[].name" -o tsv)
  if [ -z "$SERVICE_BUS_NAMESPACES" ]; then
    echo "No Service Bus namespaces found in the resource group: $RESOURCE_GROUP"
  else
    for NAMESPACE in $SERVICE_BUS_NAMESPACES; do
      TLS_VERSION="TLS 1.2 (Default)"  # Assuming default TLS version
      echo "Service Bus,$NAMESPACE,$TLS_VERSION" >> $OUTPUT_FILE
    done
  fi

  #### Storage Accounts
  STORAGE_ACCOUNTS=$(az storage account list --resource-group "$RESOURCE_GROUP" --query "[].name" -o tsv)
  if [ -z "$STORAGE_ACCOUNTS" ]; then
    echo "No Storage Accounts found in the resource group: $RESOURCE_GROUP"
  else
    for STORAGE_ACCOUNT in $STORAGE_ACCOUNTS; do
      TLS_VERSION=$(az storage account show --name "$STORAGE_ACCOUNT" --resource-group "$RESOURCE_GROUP" --query "minimumTlsVersion" -o tsv)
      TLS_VERSION=${TLS_VERSION:-"TLS 1.2 (Default)"}
      echo "Storage Account,$STORAGE_ACCOUNT,$TLS_VERSION" >> $OUTPUT_FILE
    done
  fi

  #### VPN Gateways
  VPN_GATEWAYS=$(az network vnet-gateway list --resource-group "$RESOURCE_GROUP" --query "[].name" -o tsv)
  if [ -z "$VPN_GATEWAYS" ]; then
    echo "No VPN Gateways found in the resource group: $RESOURCE_GROUP"
  else
    for GATEWAY in $VPN_GATEWAYS; do
      TLS_VERSION="TLS 1.2 (Default)"  # Assuming default TLS version
      echo "VPN Gateway,$GATEWAY,$TLS_VERSION" >> $OUTPUT_FILE
    done
  fi

done

echo "TLS versions for Azure resources have been saved to $OUTPUT_FILE"
