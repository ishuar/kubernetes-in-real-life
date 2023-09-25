output "external_secrets_operator_client_id" {
  value = azurerm_user_assigned_identity.external_secrets_operator.client_id
}

output "tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}
