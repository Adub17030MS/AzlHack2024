#!/bin/bash

set -e

ROOT_FOLDER=$(pwd)
SUBSCRIPTION_ID="" # use b8f169b2-5b23-444a-ae4b-19a31b5e3652 for EdgeOS_Mariner_Platform_dev
RESOURCE_GROUP_BASE_NAME="AzureLinuxTestSandbox"
DATE_STRING=$(date +%Y%m%d%H%M)
LOCATION="West US2"
TEMPLATE_FILE="$ROOT_FOLDER/provisioning/ubuntu-deployment-template.json"
PARAMETERS_FILE="$ROOT_FOLDER/provisioning/ubuntu-deployment-parameters.json"
TEMPLATE_FILE_CONTENT=$(cat "$TEMPLATE_FILE")
PARAMETERS_FILE_CONTENT=$(cat "$PARAMETERS_FILE")
DEPLOYMENT_BASE_NAME="UbuntuDeployment"

RESOURCE_GROUP_NAME="${RESOURCE_GROUP_BASE_NAME}-${DATE_STRING}"

# display template content
echo "Using template file: $TEMPLATE_FILE"
echo "Template file content:"
echo "$TEMPLATE_FILE_CONTENT"

# display parameters content
echo "Using parameters file: $PARAMETERS_FILE"
echo "Parameters file content:"
echo "$PARAMETERS_FILE_CONTENT"

is_logged_into_az() {
    az account show -o none 2>/dev/null
    return $?
}

set_subscription() {
    az account set --subscription "$SUBSCRIPTION_ID"
}

create_resource_group() {
    echo "Checking if resource group $RESOURCE_GROUP_NAME exists"
    resource_group_exists=$(az group exists --name "$RESOURCE_GROUP_NAME")

    echo "Resource group exists: $resource_group_exists"

    if [ "$resource_group_exists" == "true" ]; then
        echo "Resource group $RESOURCE_GROUP_NAME already exists"
    else
        echo "Creating resource group $RESOURCE_GROUP_NAME in $LOCATION"
        az group create --name "$RESOURCE_GROUP_NAME" --location "$LOCATION"
    fi
}

provision_vm() {
    local deployment_name="$DEPLOYMENT_BASE_NAME-${DATE_STRING}"

    echo "Deploying VM to resource group $RESOURCE_GROUP_NAME"

    az deployment group create \
        --name "$deployment_name" \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --template-file "$TEMPLATE_FILE" \
        --parameters "$PARAMETERS_FILE"
}

if ! is_logged_into_az; then
    echo "Not logged into Azure. Logging in..."
    az login
fi

set_subscription

create_resource_group

provision_vm

echo "finished provisioning the VM"
