#!/bin/bash

set -e

ROOT_FOLDER=$(pwd)
SUBSCRIPTION_ID="b8f169b2-5b23-444a-ae4b-19a31b5e3652" # use b8f169b2-5b23-444a-ae4b-19a31b5e3652 for EdgeOS_Mariner_Platform_dev
RESOURCE_GROUP_BASE_NAME="AzureLinuxTestSandbox"
DATE_STRING=$(date +%Y%m%d%H%M)
LOCATION="West US2"
TEMPLATE_FILE="$ROOT_FOLDER/provisioning/ubuntu-deployment-template.json"
PARAMETERS_FILE="$ROOT_FOLDER/provisioning/ubuntu-deployment-parameters.json"
FILLED_PARAMETER_FILE_NAME="filled-parameters.json"
FILLED_PARAMETER_FILE_LOCATION="$ROOT_FOLDER/provisioning/$FILLED_PARAMETER_FILE_NAME"
TEMPLATE_FILE_CONTENT=$(cat "$TEMPLATE_FILE")
PARAMETERS_FILE_CONTENT=$(cat "$PARAMETERS_FILE")
DEPLOYMENT_BASE_NAME="UbuntuDeployment"
SSH_KEY_FILE_NAME="sandbox_id_rsa"
SSH_KEY_BASE_LOCATION="$HOME/.ssh"
PRIVATE_KEY_LOCATION="$SSH_KEY_BASE_LOCATION"/"$SSH_KEY_FILE_NAME"
PUBLIC_KEY_LOCATION="$SSH_KEY_BASE_LOCATION"/"$SSH_KEY_FILE_NAME.pub"

# RESOURCE_GROUP_NAME="AzureLinuxTestSandbox-202406131829"
RESOURCE_GROUP_NAME="${RESOURCE_GROUP_BASE_NAME}-${DATE_STRING}"

echo "PWD: $ROOT_FOLDER"

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

    if [ $(az group exists --name "$RESOURCE_GROUP_NAME") = false ]; then
        echo "Creating resource group $RESOURCE_GROUP_NAME in $LOCATION"
        az group create --name "$RESOURCE_GROUP_NAME" --location "$LOCATION"
    else
        echo "Resource group $RESOURCE_GROUP_NAME already exists"
    fi
}

provision_vm() {
    local deployment_name="$DEPLOYMENT_BASE_NAME-${DATE_STRING}"

    echo "Deploying VM to resource group $RESOURCE_GROUP_NAME"

    az deployment group create \
        --name "$deployment_name" \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --template-file "$TEMPLATE_FILE" \
        --parameters "$FILLED_PARAMETER_FILE_LOCATION"

    echo "VM deployment complete, sleeping for 10 seconds to let the VM start up"
    sleep 10
}

generate_ssh_key() {
    if [ -f "$PUBLIC_KEY_LOCATION" ]; then
        echo "SSH key already exists"
        return
    fi

    ssh-keygen -t rsa -b 4096 -C "azure vm preview test" -N "" -f "$PRIVATE_KEY_LOCATION"
    chmod 600 "$PUBLIC_KEY_LOCATION"
    chmod 600 "$PRIVATE_KEY_LOCATION"
}

update_parameters_file() {
    UPDATED_PARAMETERS_FILE_CONTENT=$(jq ".parameters.adminPublicKey.value = \"$(cat ~/.ssh/$SSH_KEY_FILE_NAME.pub)\"" <<< "$PARAMETERS_FILE_CONTENT")

    echo "updated parameters content into $ROOT_FOLDER/provisioning/$FILLED_PARAMETER_FILE_NAME"

    echo "$UPDATED_PARAMETERS_FILE_CONTENT" > "$FILLED_PARAMETER_FILE_LOCATION"
}

if ! is_logged_into_az; then
    echo "Not logged into Azure. Logging in..."
    az login
fi

generate_ssh_key

update_parameters_file

set_subscription

create_resource_group

provision_vm

VM_IP=$(az vm show -d -g "$RESOURCE_GROUP_NAME" -n AzureLinuxSandbox --query publicIps -o tsv)

echo "finished provisioning the VM with IP $VM_IP"

echo "Installing requirements:"

POST_PROVISION_SCRIPT_NAME=$1
POST_PROVISION_SCRIPT_LOCATION="$ROOT_FOLDER/provisioning/$POST_PROVISION_SCRIPT_NAME"
POST_INSTALL_VM_FOLDER_LOCATION="/home/azluser/postinstall"

ssh-keygen -f "$HOME/.ssh/known_hosts" -R "$VM_IP"

echo "sending $POST_PROVISION_SCRIPT_NAME to the VM in location $POST_INSTALL_VM_FOLDER_LOCATION"

# create director for postinstall scripts to live on the target VM
echo "creating directory $POST_INSTALL_VM_FOLDER_LOCATION on the VM"
ssh -i $PRIVATE_KEY_LOCATION -o StrictHostKeyChecking=no "azluser@$VM_IP" "mkdir -p $POST_INSTALL_VM_FOLDER_LOCATION"

echo "copying $POST_PROVISION_SCRIPT_NAME to the VM"
scp -i $PRIVATE_KEY_LOCATION "$POST_PROVISION_SCRIPT_LOCATION" "azluser@$VM_IP":$POST_INSTALL_VM_FOLDER_LOCATION

echo "disable ubuntu pop-ups"
ssh -i $PRIVATE_KEY_LOCATION -t "azluser@$VM_IP" "sudo apt-get remove -y needrestart"

echo "running $POST_PROVISION_SCRIPT_NAME on the VM"
ssh -i $PRIVATE_KEY_LOCATION -t "azluser@$VM_IP" "$POST_INSTALL_VM_FOLDER_LOCATION/$POST_PROVISION_SCRIPT_NAME"
