terraform {
  backend "azurerm" {
    resource_group_name  = "rg-kubernetes-projects-backend"
    storage_account_name = "stgk8sprojweu01"
    container_name       = "tfstate"
    key                  = "kubernetes-projects"
  }
}
