resource "azurerm_resource_group" "aks" {
  name     = "rg-${local.tags["github_repo"]}"
  location = "West Europe"
  tags     = local.tags
}

module "ssh_key_generator" {
  source               = "github.com/ishuar/terraform-sshkey-generator?ref=v1.1.0"
  algorithm            = "RSA"
  private_key_filename = "${path.module}/aks-private-key"
  file_permission      = "600"
}

##* Managed Identity is required for Vnet-Api Integration

# Error: creating Kubernetes Cluster (Subscription: "c5bcdb0e-4322-4305-8f70-fc66eff37c1a"
# Resource Group Name: "rg-kubernetes-projects"
# Kubernetes Cluster Name: "container-registry-kubernetes-projects"): managedclusters.ManagedClustersClient#CreateOrUpdate: Failure sending request: StatusCode=0 --
# Original Error: Code="OnlySupportedOnUserAssignedMSICluster" Message="System-assigned managed identity not supported for custom resource.
# Please use user-assigned managed identity."

resource "azurerm_user_assigned_identity" "aks" {
  name                = "id-aks-docker-registry-${local.tags["github_repo"]}"
  resource_group_name = azurerm_resource_group.aks.name
  location            = azurerm_resource_group.aks.location
}

# data "azurerm_kubernetes_service_versions" "current" {
#   location        = "West Europe"
#   include_preview = true
# }

## FluxCD enabled Azure Kubernetes Cluster
## ? ref : https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/tutorial-use-gitops-flux2?tabs=azure-cli#for-azure-kubernetes-service-clusters

module "flux_ui" {
  source  = "ishuar/aks/azure"
  version = "1.6.0"


  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  name                = "container-registry-${local.tags["github_repo"]}"
  dns_prefix          = "fluxaks"
  key_data            = trimspace(module.ssh_key_generator.public_ssh_key)
  # kubernetes_version  = azurerm_kubernetes_service_versions.current.latest_version
  tags = local.tags

  ## Identity
  identity_type = "UserAssigned"
  identity_ids  = [azurerm_user_assigned_identity.aks.id]

  ## Default node pool
  default_node_pool_name                = "system"
  default_node_pool_enable_auto_scaling = true
  default_node_pool_vm_size             = "standard_d2ds_v5"
  default_node_pool_min_count           = 1
  default_node_pool_max_count           = 2
  default_node_pool_max_pods            = 110

  ## Api service access profile
  enable_api_server_access_profile    = true
  vnet_integration_enabled            = true
  api_server_access_profile_subnet_id = azurerm_subnet.aks_api.id

  ## Networking
  vnet_subnet_id      = azurerm_subnet.aks_node.id
  network_plugin      = "azure"
  network_plugin_mode = "overlay"
  service_cidrs       = ["100.1.0.0/16"]
  pod_cidrs           = ["100.2.0.0/16"]
  dns_service_ip      = "100.1.0.100"
  # ebpf_data_plane     = "cilium"
  network_policy = "calico"

  ## Azure Active Directory
  local_account_disabled = true
  aad_rbac_enabled       = true ## Enable the feature for Azure RBAC with AKS
  aad_rbac_managed       = true ## Manged RBAC
  aad_azure_rbac_enabled = true ## Azure AAD and Azure RBAC ( No K8s RBAC )


  ## Workload Identity
  workload_identity_enabled = true
  oidc_issuer_enabled       = true

  ## Flux
  enable_fluxcd                                  = true
  fluxcd_extension_name                          = "fluxcd"
  fluxcd_configuration_name                      = "flux-ui-dashboard"
  fluxcd_extension_release_namespace             = "flux-system"
  fluxcd_namespace                               = local.flux_manifests_namespace ##?This Namespace should be used in k8s manifests sync with AKS fluxCD when multi tenancy is enabled.
  fluxcd_scope                                   = "cluster"
  fluxcd_git_repository_url                      = "https://github.com/ishuar/kubernetes-projects"
  fluxcd_git_repository_sync_interval_in_seconds = 60
  fluxcd_extension_configuration_settings = {
    "multiTenancy.enforce" = false
  }

  kustomizations = [
    {
      name                     = "infrastructure"
      path                     = "./azure-kubernetes-service/flux-extension-and-flux-dashboard/fluxcd/infrastructure"
      sync_interval_in_seconds = 60
    },
    {
      name                     = "external-secrets-store"
      path                     = "./azure-kubernetes-service/flux-extension-and-flux-dashboard/fluxcd/secret-store"
      sync_interval_in_seconds = 60
      depends_on               = ["infrastructure"]
    },
    {
      name                     = "cluster-issuer"
      path                     = "./azure-kubernetes-service/flux-extension-and-flux-dashboard/fluxcd/cluster-issuer"
      sync_interval_in_seconds = 60
      depends_on               = ["infrastructure"]
    },
    {
      name                     = "weave-flux-ui"
      path                     = "./azure-kubernetes-service/flux-extension-and-flux-dashboard/fluxcd/weave-flux-ui"
      sync_interval_in_seconds = 60
      depends_on               = ["infrastructure", "external-secrets-store", "cluster-issuer"]
    },
  ]
  ### This is experimental only Feature
  enable_fluxcd_az_providers = true
}

## In case not able to delete aks extension.
### az k8s-extension delete  --resource-group rg-aks-module-test-euw --cluster-name minimal-example --cluster-type managedClusters --name flux-cd --force

## Assign on the resource group level for Nginx ingress controller ( vnet integration requires on subnet level )
resource "azurerm_role_assignment" "aks_mi_network_contributor" {
  scope                = azurerm_resource_group.aks.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}
