data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}

##? KV is public atm, can plan only from the AKS network.
resource "azurerm_key_vault" "k8s_flux" {
  name                       = "k8s-projects-secrets-01"
  location                   = azurerm_resource_group.aks.location
  resource_group_name        = azurerm_resource_group.aks.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  enable_rbac_authorization  = true
}

resource "azurerm_role_assignment" "kv_rbac" {
  for_each = {
    "Key Vault Administrator" = data.azurerm_client_config.current.object_id
    "Key Vault Reader"        = azurerm_user_assigned_identity.external_secrets_operator.principal_id
  }

  principal_id         = each.value
  scope                = azurerm_key_vault.k8s_flux.id
  role_definition_name = each.key
}

# #######
# ## SECRETS TO KV
# #######

# ##? Update KV with the app registration secretIds
# ##? depends on current objectID azure RBAC on kV

resource "azurerm_key_vault_secret" "client_id" {
  for_each = toset(local.service_principals)

  name         = join("-", ["spn", (each.value), "clientid"])
  content_type = "username"
  key_vault_id = azurerm_key_vault.k8s_flux.id
  value        = azuread_service_principal.this[each.value].application_id
}

resource "azurerm_key_vault_secret" "client_secret" {
  for_each = toset(local.service_principals)

  name         = join("-", ["spn", (each.value), "clientsecret"])
  content_type = "password"
  key_vault_id = azurerm_key_vault.k8s_flux.id
  value        = azuread_service_principal_password.this[each.value].value
}

resource "azurerm_key_vault_secret" "subscription_and_tenant_id" {
  for_each = {
    subscriptionid = data.azurerm_client_config.current.subscription_id
    tenantid       = data.azurerm_client_config.current.tenant_id
  }

  name         = each.key
  content_type = "generic"
  key_vault_id = azurerm_key_vault.k8s_flux.id
  value        = each.value
}
