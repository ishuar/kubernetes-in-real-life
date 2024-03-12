#! /usr/bin/env bash

##* This script helps to enable features required for AKS cluster in the Microsoft.ContainerService namepsace
##* Modify "FEATURES" bash array with the features required.

FEATURES=("EnableAPIServerVnetIntegrationPreview")

for feature in "${FEATURES[@]}"; do
  printf '\e[1;32m%-6s\e[0m\n' "Registerring $feature to azure Microsoft.ContainerService namepsace...."
  az feature register --namespace "Microsoft.ContainerService" --name "$feature"
  for i in {1..3}; do
    echo "waiting for $feature to be registered with azure Microsoft.ContainerService namepsace......."
    sleep 1
  done
done

for feature in "${FEATURES[@]}"; do
  REGISTRATION_STATUS="$(az feature show --namespace "Microsoft.ContainerService" --name "$feature" --output json --query "properties.state")"
  for i in {1..20}; do
    if [[ "${REGISTRATION_STATUS}" =~ "Registered" ]]; then
      echo "$feature Registered Successfully"
      break
    else
      echo "Attempt $i/20 for $feature"
      sleep 1
    fi
  done
done
