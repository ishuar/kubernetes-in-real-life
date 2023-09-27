#### Application Service Principals #####

##? HINT: It might be easier to create the emtpty app and adjust in portal and import the changes from plan diff.
##? Check Enterprise Application for Sign in Logs
resource "azuread_application" "flux_ui" {
  display_name     = "flux-dashboard-oidc"
  owners           = [data.azurerm_client_config.current.object_id]
  sign_in_audience = "AzureADMyOrg"

  web {
    redirect_uris = ["https://flux-dashboard.k8s.learndevops.in/oauth2/callback"]
    implicit_grant {
      access_token_issuance_enabled = false
      id_token_issuance_enabled     = false
    }
  }
  identifier_uris = [
    "api://6c74d507-7549-41da-bd34-c7d445facad1",
  ]
  group_membership_claims = [
    "ApplicationGroup",
  ]
  optional_claims {
    access_token {
      essential = false
      name      = "groups"
    }
    id_token {
      essential = false
      name      = "groups"
    }
    saml2_token {
      essential = false
      name      = "groups"
    }
  }

  /*
  Documentation on resource_app_id values for Microsoft APIs can be difficult to find,
  but you can use the Azure CLI to find them.
  (e.g. az ad sp list --display-name "Microsoft Graph" --query '[].{appDisplayName:appDisplayName, appId:appId}')
  Microsoft reference for IDs : https://learn.microsoft.com/en-us/graph/permissions-reference#openid-connect-oidc-scopes
  */
  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph

    ##  * All permissions and IDs: https://learn.microsoft.com/en-us/graph/permissions-reference#all-permissions-and-ids *
    resource_access {
      id   = "14dad69e-099b-42c9-810b-d002981feec1"
      type = "Scope"
    }
    resource_access {
      id   = "7427e0e9-2fba-42fe-b0c0-848c9e6a8182"
      type = "Scope"
    }
    resource_access {
      id   = "37f7f235-527c-4136-accd-4a02d197296e"
      type = "Scope"
    }
    resource_access {
      id   = "64a6cdd6-aab1-4aaf-94b8-3cc8405e90d0"
      type = "Scope"
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
