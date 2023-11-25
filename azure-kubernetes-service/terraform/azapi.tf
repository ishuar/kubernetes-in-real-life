resource "azapi_resource_action" "container_service_provider_registration" {
  type        = "Microsoft.ContainerService@2017-07-01"
  resource_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/providers/Microsoft.ContainerService"
  action      = "register"
  method      = "POST"

  depends_on = [
    terraform_data.az_feature_register
   ]
}

resource "terraform_data" "az_feature_register" {
triggers_replace = [
    data.azurerm_client_config.current.subscription_id
  ]
  provisioner "local-exec" {
    #### script to enable/register the required namespaces with  boolean argument to upgrade az cli or not.
    command = "${path.module}/../scripts/register-container-service-features.sh"
    interpreter = [
      "/bin/bash", "-c"
    ]
  }
}

