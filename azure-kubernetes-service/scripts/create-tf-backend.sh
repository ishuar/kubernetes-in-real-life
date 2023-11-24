#! /usr/bin/env bash

export LOCATION="westeurope"
export RESOURCE_GROUP_NAME="rg-kubernetes-projects-backend"
export STORAGE_ACCOUNT_NAME="stgk8sprojweu01"

##? https://github.com/ishuar/terraform-ansible-azure/blob/main/scripts/set-up-terraform-remote-state.sh
bash <(curl -s https://raw.githubusercontent.com/ishuar/terraform-ansible-azure/main/scripts/set-up-terraform-remote-state.sh )
