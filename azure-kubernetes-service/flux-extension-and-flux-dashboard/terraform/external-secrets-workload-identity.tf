resource "azurerm_user_assigned_identity" "external_secrets_operator" {
  location            = azurerm_resource_group.aks.location
  name                = "uid-external-secrets-operator"
  resource_group_name = azurerm_resource_group.aks.name
}

resource "azurerm_federated_identity_credential" "external_secrets_operator" {
  name                = "federated-external-secrets-operator"
  resource_group_name = azurerm_resource_group.aks.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = module.flux_ui.azurerm_kubernetes_cluster.oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.external_secrets_operator.id
  subject             = "system:serviceaccount:${local.flux_manifests_namespace}:sa-external-secrets-operator"
}
