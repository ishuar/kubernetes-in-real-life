# data "azurerm_client_config" "current" {}

# resource "azapi_resource_action" "test" {
#   type        = "Microsoft.ContainerService@2017-07-01"
#   resource_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/providers/Microsoft.ContainerService"
#   action      = "register"
#   method      = "POST"
# }

# resource "azapi_resource_action" "test2" {
#   type        = "Microsoft.Features/providers/features@2017-07-01"
#   resource_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/providers/Microsoft.Features/providers/microsoft.ContainerService/features/EnableAPIServerVnetIntegrationPreview"
#   action      = "register"
#   method      = "POST"
# }


# resource "azurerm_resource_provider_registration" "example" {
#   name = "Microsoft.ContainerService"

#   feature {
#     name       = "EnableAPIServerVnetIntegrationPreview"
#     registered = true
#   }
# }
