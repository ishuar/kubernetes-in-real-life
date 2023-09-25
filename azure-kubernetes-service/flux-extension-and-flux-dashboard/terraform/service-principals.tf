resource "azuread_application" "this" {
  for_each = toset(local.service_principals)

  display_name = each.value
  owners       = [data.azurerm_client_config.current.object_id]
}

resource "azuread_service_principal" "this" {
  for_each = toset(local.service_principals)

  application_id               = azuread_application.this[each.value].application_id
  app_role_assignment_required = false
  owners                       = [data.azurerm_client_config.current.object_id]
}

resource "azuread_service_principal_password" "this" {
  for_each             = toset(local.service_principals)
  service_principal_id = azuread_service_principal.this[each.value].id
}
