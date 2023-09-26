#### Application Service Principals #####
resource "azuread_application" "flux_ui" {
  display_name     = "flux-dashboard-oidc"
  owners           = [data.azurerm_client_config.current.object_id]
  sign_in_audience = "AzureADMyOrg"

  web {
    redirect_uris = ["https://flux-dashboard.k8s.learndevops.in/"]
    implicit_grant {
      access_token_issuance_enabled = true
      id_token_issuance_enabled     = true
    }
  }
}

resource "azuread_service_principal" "flux_ui" {
  application_id               = azuread_application.flux_ui.application_id
  app_role_assignment_required = false
  owners                       = [data.azurerm_client_config.current.object_id]
  notes                        = "This SPN is used for flux-dashboard-oidc in ${local.tags["github_repo"]} github repo in ${local.tags["directory_level"]} sub project"
}

resource "azuread_service_principal_password" "flux_ui" {
  service_principal_id = azuread_service_principal.flux_ui.id
}
