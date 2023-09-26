resource "azurerm_user_assigned_identity" "this" {
  for_each = toset(concat(local.key_vault_access, local.dns_admin_access))

  location            = azurerm_resource_group.aks.location
  name                = "uid-${each.value}"
  resource_group_name = azurerm_resource_group.aks.name
}

resource "azurerm_federated_identity_credential" "this" {
  for_each = toset(concat(local.key_vault_access, local.dns_admin_access))

  name                = "federated-external-secrets-operator"
  resource_group_name = azurerm_resource_group.aks.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = module.flux_ui.azurerm_kubernetes_cluster.oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.this[each.value].id
  subject             = "system:serviceaccount:${local.flux_manifests_namespace}:sa-${each.value}"
}

resource "azurerm_role_assignment" "dns_admin" {
  for_each = toset(local.dns_admin_access)

  scope                = azurerm_dns_zone.k8s_learndevops_in.id
  role_definition_name = "DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.this[each.value].principal_id
}
