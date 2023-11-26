#! /usr/bin/env bash

##* This script creates the terraform backend for azure, storage acccount and contaier for terraform remote state.
##* below variables can be set on the runtime by using `export <VARIABLE_NAME>=<VALUE>`

LOCATION=${LOCATION:-"westeurope"}
RESOURCE_GROUP_NAME=${RESOURCE_GROUP_NAME:-"rg-kubernetes-projects-backend"}
STORAGE_ACCOUNT_NAME=${1:-"stgk8sprojweu01"}
CONTAINER_NAME=${CONTAINER_NAME:-"tfstate"}

export LOCATION
export RESOURCE_GROUP_NAME
export STORAGE_ACCOUNT_NAME

##? https://github.com/ishuar/terraform-ansible-azure/blob/main/scripts/set-up-terraform-remote-state.sh
bash <(curl -s https://raw.githubusercontent.com/ishuar/terraform-ansible-azure/main/scripts/set-up-terraform-remote-state.sh)
