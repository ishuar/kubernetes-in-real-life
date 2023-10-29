output "name_client_id_key_pair" {
  value = {
    for v in azurerm_user_assigned_identity.this : v.name => v.client_id
  }
  description = "clientID for the managed identities in the format 'name = client_id' for usage in kubernetes manifests without accessing portal."
}

output "tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}

output "subscription_id" {
  value = data.azurerm_client_config.current.subscription_id
}
output "flux_ui_client_id_name" {
  value = azurerm_key_vault_secret.flux_ui_client_id.name
}
output "flux_ui_client_secret_name" {
  value = azurerm_key_vault_secret.flux_ui_client_secret.name
}

output "dns_zone_name_servers" {
  value = azurerm_dns_zone.k8s_learndevops_in.name_servers
}
