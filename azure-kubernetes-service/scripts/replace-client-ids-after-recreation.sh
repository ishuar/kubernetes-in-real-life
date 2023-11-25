#! /usr/bin/env bash

## This script will get the latest clientIDs for cert-manager, external-dns and external-secret-operator
## from terraform ouputs and update the respective files , so that infra can be recreated and no manual changees
## should be made.


CURRENT_DIR="$(pwd)"
GITOPS_DIR="$(dirname "$CURRENT_DIR")/gitops/fluxcd"

CERT_MANAGER_CLIENT_ID="$(terraform output --json name_client_id_key_pair | jq '."uid-cert-manager"')"
EXTERNAL_DNS_CLIENT_ID="$(terraform output --json name_client_id_key_pair | jq '."uid-external-dns"')"
EXTERNAL_SECRETS_OPERATOR_CLIENT_ID="$(terraform output --json name_client_id_key_pair | jq '."uid-external-secrets-operator"')"

export CERT_MANAGER_CLIENT_ID ## Required for env(CERT_MANAGER_CLIENT_ID)

yq eval -i '.spec.acme.solvers.[].dns01.azureDNS.managedIdentity.clientID = env(CERT_MANAGER_CLIENT_ID)' "$GITOPS_DIR/cluster-issuer/cluster-issuer.yaml"

APPLICATIONS_WITH_CLIENT_ID_MAP=(
  cert-manager:"$CERT_MANAGER_CLIENT_ID"
  external-dns:"$EXTERNAL_DNS_CLIENT_ID"
  external-secrets-operator:"$EXTERNAL_SECRETS_OPERATOR_CLIENT_ID"
)

for app in "${APPLICATIONS_WITH_CLIENT_ID_MAP[@]}";do
  APP_NAME="$(echo "${app}" | cut -d ':' -f1)"
  CLIENT_ID="$(echo "${app}" | cut -d ':' -f2)"
  export CLIENT_ID
  yq eval -i '.spec.values.serviceAccount.annotations."azure.workload.identity/client-id" = env(CLIENT_ID)' "$GITOPS_DIR/infrastructure/$APP_NAME/release.yaml"
done
