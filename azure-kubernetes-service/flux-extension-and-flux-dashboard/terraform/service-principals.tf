#### Application Service Principals #####

##? HINT: It might be easier to create the emtpty app and adjust in portal and import the changes from plan diff.
##? Check Enterprise Application for Sign in Logs

resource "random_uuid" "flux_aad_app" {}

## Create App registration
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
  app_role {
    allowed_member_types = ["User"]
    description          = "flux oidc admins "
    display_name         = "flux-oidc-admins"
    enabled              = true
    id                   = random_uuid.flux_aad_app.result
    value                = "admin"
  }
}

## Create Service Principal
resource "azuread_service_principal" "flux_ui" {
  application_id               = azuread_application.flux_ui.application_id
  app_role_assignment_required = false
  owners                       = [data.azurerm_client_config.current.object_id]
  notes                        = "This SPN is used for flux-dashboard-oidc in ${local.tags["github_repo"]} github repo in ${local.tags["directory_level"]} sub project"
}

## Create group for admins
resource "azuread_group" "aks_cluster_admins" {
  display_name     = "Flux-ui-cluster-admins"
  owners           = [data.azurerm_client_config.current.object_id]
  security_enabled = true

  members = [
    data.azurerm_client_config.current.object_id,
  ]
}

## Assign role to admins for the app registration / Add groups to the service principal
resource "azuread_app_role_assignment" "flux_ui" {
  app_role_id         = azuread_service_principal.flux_ui.app_role_ids["admin"]
  principal_object_id = azuread_group.aks_cluster_admins.object_id
  resource_object_id  = azuread_service_principal.flux_ui.object_id
}

resource "azuread_service_principal_password" "flux_ui" {
  service_principal_id = azuread_service_principal.flux_ui.id
}
