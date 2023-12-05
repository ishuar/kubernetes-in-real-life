#! /usr/bin/env bash

##* This script will get the latest clientIDs for cert-manager, external-dns and external-secret-operator
##* from terraform ouputs and update the respective files , so that infra can be recreated and no manual changees
##* should be made. This script should be ran once terraform apply is successful and then need to be pushed to github repo.
##! terraform , jq and yq are required to run this script.

CURRENT_DIR="$(pwd)"
GITOPS_DIR="$(dirname "$CURRENT_DIR")/gitops/fluxcd"

CERT_MANAGER_CLIENT_ID="$(terraform output --json name_client_id_key_pair | jq '."uid-cert-manager"')"
EXTERNAL_DNS_CLIENT_ID="$(terraform output --json name_client_id_key_pair | jq '."uid-external-dns"')"
EXTERNAL_SECRETS_OPERATOR_CLIENT_ID="$(terraform output --json name_client_id_key_pair | jq '."uid-external-secrets-operator"')"
VELERO_CLIENT_ID="$(terraform output --json name_client_id_key_pair | jq '."uid-velero"')"
VELERO_RESOURCE_GROUP="$(terraform output aks_resource_group_name)"


export CERT_MANAGER_CLIENT_ID ## Required for env(CERT_MANAGER_CLIENT_ID) :: different dir than infrastructure ::
yq eval -i '.spec.acme.solvers.[].dns01.azureDNS.managedIdentity.clientID = env(CERT_MANAGER_CLIENT_ID)' "$GITOPS_DIR/cluster-issuer/cluster-issuer.yaml"
CLUSTER_ISSUER_CLIENT_ID="$(yq '.spec.acme.solvers.[].dns01.azureDNS.managedIdentity.clientID' <  "$GITOPS_DIR/cluster-issuer/cluster-issuer.yaml")"
echo "cluster-issuer-client-id: $CLUSTER_ISSUER_CLIENT_ID (client-id)"

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
  echo "$APP_NAME-client-id-from-yaml-file: $UPDATED_FIELD (client-id)"
done

## VELERO Replacements

export VELERO_CLIENT_ID  ## Required for env(VELERO_CLIENT_ID) :: different dir than infrastructure ::
export VELERO_RESOURCE_GROUP
VELERO_RELEASE_YAML_FILE="$GITOPS_DIR/backup-disaster-recover/velero/release.yaml"
yq eval -i '.spec.values.serviceAccount.annotations."azure.workload.identity/client-id" = env(VELERO_CLIENT_ID)' "$VELERO_RELEASE_YAML_FILE"
yq eval -i '.spec.values.configuration.volumeSnapshotLocation[].config.resourceGroup = env(VELERO_RESOURCE_GROUP)' "$VELERO_RELEASE_YAML_FILE"
yq eval -i '.spec.values.configuration.backupStorageLocation[].config.resourceGroup = env(VELERO_RESOURCE_GROUP)' "$VELERO_RELEASE_YAML_FILE"

## Print the change
UPDATED_VELERO_CLIENT_ID="$(yq '.spec.values.serviceAccount.annotations."azure.workload.identity/client-id"' < "$VELERO_RELEASE_YAML_FILE")"
UPDATED_VELERO_RESOURCE_GROUP="$(yq '.spec.values.configuration.volumeSnapshotLocation[].config.resourceGroup' < "$VELERO_RELEASE_YAML_FILE")"

echo "velero-client-id-from-yaml-file: $UPDATED_VELERO_CLIENT_ID (client-id)"
echo "velero-rg-name-from-yaml-file: $UPDATED_VELERO_RESOURCE_GROUP (resource-group)"
