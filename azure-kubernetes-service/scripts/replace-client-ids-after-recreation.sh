#! /usr/bin/env bash

##* This script will get the latest clientIDs for cert-manager, external-dns and external-secret-operator
##* from terraform ouputs and update the respective files , so that infra can be recreated and no manual changees
##* should be made. This script should be ran once terraform apply is successful and then need to be pushed to github repo.
##! terraform , jq and yq are required to run this script.
## this script will only work terraform dir as terraform outputs are only available there.

## Colours output
YELLOW="$(tput -Txterm setaf 3)"
RESET="$(tput -Txterm sgr0)"
GREEN="$(tput -Txterm setaf 2)"


CURRENT_DIR="$(pwd)"
GITOPS_DIR="$(dirname "$CURRENT_DIR")/gitops/fluxcd"

CERT_MANAGER_CLIENT_ID="$(terraform output --json name_client_id_key_pair | jq '."uid-cert-manager"')"
EXTERNAL_DNS_CLIENT_ID="$(terraform output --json name_client_id_key_pair | jq '."uid-external-dns"')"
EXTERNAL_SECRETS_OPERATOR_CLIENT_ID="$(terraform output --json name_client_id_key_pair | jq '."uid-external-secrets-operator"')"
VELERO_CLIENT_ID="$(terraform output --json name_client_id_key_pair | jq '."uid-velero"')"
VELERO_BACKUP_RESOURCE_GROUP="$(terraform output velero_backup_resource_group_name)"


export CERT_MANAGER_CLIENT_ID ## Required for env(CERT_MANAGER_CLIENT_ID) :: different dir than infrastructure ::
yq eval -i '.spec.acme.solvers.[].dns01.azureDNS.managedIdentity.clientID = env(CERT_MANAGER_CLIENT_ID)' "$GITOPS_DIR/cluster-issuer/cluster-issuer.yaml"
CLUSTER_ISSUER_CLIENT_ID="$(yq '.spec.acme.solvers.[].dns01.azureDNS.managedIdentity.clientID' <  "$GITOPS_DIR/cluster-issuer/cluster-issuer.yaml")"
echo "${YELLOW}cluster-issuer-client-id${RESET}: $CLUSTER_ISSUER_CLIENT_ID ${GREEN}(client-id)${RESET}"

APPLICATIONS_WITH_CLIENT_ID_MAP=(
  cert-manager:"$CERT_MANAGER_CLIENT_ID"
  external-dns:"$EXTERNAL_DNS_CLIENT_ID"
  external-secrets-operator:"$EXTERNAL_SECRETS_OPERATOR_CLIENT_ID"
)

for app in "${APPLICATIONS_WITH_CLIENT_ID_MAP[@]}"; do
  APP_NAME="$(echo "${app}" | cut -d ':' -f1)"
  CLIENT_ID="$(echo "${app}" | cut -d ':' -f2)"
  export CLIENT_ID
  yq eval -i '.spec.values.serviceAccount.annotations."azure.workload.identity/client-id" = env(CLIENT_ID)' "$GITOPS_DIR/infrastructure/$APP_NAME/release.yaml"
  ## Print the change
  UPDATED_FIELD="$(yq '.spec.values.serviceAccount.annotations."azure.workload.identity/client-id"' <  "$GITOPS_DIR/infrastructure/$APP_NAME/release.yaml")"
  echo "${YELLOW}${YELLOW}$APP_NAME-client-id-from-yaml-file${RESET}${RESET}: $UPDATED_FIELD ${GREEN}(client-id)${RESET}"
done

## VELERO Replacements

export VELERO_CLIENT_ID  ## Required for env(VELERO_CLIENT_ID) :: different dir than infrastructure ::
export VELERO_BACKUP_RESOURCE_GROUP
VELERO_YAML_FILES="$GITOPS_DIR/backup-disaster-recovery/velero"
yq eval -i '.spec.values.serviceAccount.server.annotations."azure.workload.identity/client-id" = env(VELERO_CLIENT_ID)' "$VELERO_YAML_FILES/release.yaml"
yq eval -i '.spec.values.configuration.volumeSnapshotLocation[].config.resourceGroup = env(VELERO_BACKUP_RESOURCE_GROUP)' "$VELERO_YAML_FILES/release.yaml"
yq eval -i '.spec.values.configuration.backupStorageLocation[].config.resourceGroup = env(VELERO_BACKUP_RESOURCE_GROUP)' "$VELERO_YAML_FILES/release.yaml"
yq eval -i '.parameters.resourceGroup = env(VELERO_BACKUP_RESOURCE_GROUP)' "$VELERO_YAML_FILES/volumeSnapshotClass.yaml"

## Print the change
UPDATED_VELERO_CLIENT_ID="$(yq '.spec.values.serviceAccount.server.annotations."azure.workload.identity/client-id"' < "$VELERO_YAML_FILES"/release.yaml)"
UPDATED_VELERO_BACKUP_RESOURCE_GROUP="$(yq '.spec.values.configuration.volumeSnapshotLocation[].config.resourceGroup' < "$VELERO_YAML_FILES"/release.yaml)"

echo "${YELLOW}velero-client-id-from-yaml-file${RESET}: $UPDATED_VELERO_CLIENT_ID ${GREEN}(client-id)${RESET}"
echo "${YELLOW}velero-rg-name-from-yaml-file${RESET}: $UPDATED_VELERO_BACKUP_RESOURCE_GROUP ${GREEN}(resource-group)${RESET}"
