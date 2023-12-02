output "name_client_id_key_pair" {
  value = {
    for v in azurerm_user_assigned_identity.this : v.name => v.client_id
  }
  description = "clientID for the managed identities in the format 'name = client_id' for usage in kubernetes manifests without accessing portal."
}

output "tenant_id" {
  value       = data.azurerm_client_config.current.tenant_id
  description = " Tenant ID in which infrastructure is deployed."
}

output "subscription_id" {
  value       = data.azurerm_client_config.current.subscription_id
  description = "Subscription ID in which infrastrucutre is deployed."
}
output "flux_dashboard_client_id_name" {
  value       = azurerm_key_vault_secret.flux_dashboard_client_id.name
  description = "Client ID used for flux dashboard ( weave gitops ) service principal."
}
output "flux_dashboard_client_secret_name" {
  value       = azurerm_key_vault_secret.flux_dashboard_client_secret.name
  description = "Client secret used for flux dashboard ( weave gitops ) service principal."
}

output "dns_zone_name_servers" {
  value       = azurerm_dns_zone.k8s_learndevops_in.name_servers
  description = "List of DNS nameservers to which domain registrar has to delegate DNS traffic. e.g from Godady to azure public DNS zone."
}
