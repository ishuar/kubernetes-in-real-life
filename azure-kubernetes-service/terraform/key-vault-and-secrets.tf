data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}

##? KV is public atm, can plan only from the AKS network.
resource "azurerm_key_vault" "k8s_flux" {
  name                       = var.secret_management_key_vault_name
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
    "Key Vault Secrets User"  = azurerm_user_assigned_identity.this["external-secrets-operator"].principal_id
  }

  principal_id         = each.value
  scope                = azurerm_key_vault.k8s_flux.id
  role_definition_name = each.key
}

# #######
# ## SECRETS TO KV
# #######
resource "random_password" "grafana_admin_password" {
  length           = 32
  min_upper        = 1
  min_special      = 1
  override_special = "!#$%&*@"
}

# ##? Update KV with the app registration secretIds
# ##? depends on current objectID azure RBAC on kV
resource "azurerm_key_vault_secret" "subscription_and_tenant_id" {
  for_each = {
    subscriptionid                  = data.azurerm_client_config.current.subscription_id
    tenantid                        = data.azurerm_client_config.current.tenant_id
    grafana-admin-user              = "admin"
    grafana-admin-password          = random_password.grafana_admin_password.result
    kube-prom-stack-basic-auth-data = "admin:$apr1$d1RF45nH$YC0/598/voaRA/4vhw9T6/" ##! encrypted (!! Hint ::Think:: !! )
    discord-webhook-url             = var.ALERTMANAGER_DISCORD_CHANNEL_RECEIVER_URL
  }

  name         = each.key
  content_type = "generic"
  key_vault_id = azurerm_key_vault.k8s_flux.id
  value        = each.value
  depends_on = [
    azurerm_role_assignment.kv_rbac
  ]
}

#### Application Secret to Key Vault ###
resource "azurerm_key_vault_secret" "flux_dashboard_client_id" {
  name         = join("-", ["spn", "flux-dashboard-oidc", "clientid"])
  content_type = "username"
  key_vault_id = azurerm_key_vault.k8s_flux.id
  value        = azuread_service_principal.flux_dashboard.client_id

  depends_on = [
    azurerm_role_assignment.kv_rbac
  ]
}

resource "azurerm_key_vault_secret" "flux_dashboard_client_secret" {
  name         = join("-", ["spn", "flux-dashboard-oidc", "clientsecret"])
  content_type = "password"
  key_vault_id = azurerm_key_vault.k8s_flux.id
  value        = azuread_service_principal_password.flux_dashboard.value
  depends_on = [
    azurerm_role_assignment.kv_rbac
  ]
}
