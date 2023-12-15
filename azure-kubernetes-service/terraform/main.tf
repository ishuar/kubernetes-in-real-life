resource "azurerm_resource_group" "aks" {
  name     = "rg-${local.tags["prefix"]}"
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

##! Error: creating Kubernetes Cluster (Subscription: "subscription_id"
##! Resource Group Name: "rg-kubernetes-projects"
##! Kubernetes Cluster Name: "flux-dashboard-kubernetes-projects"): managedclusters.ManagedClustersClient#CreateOrUpdate: Failure sending request: StatusCode=0 --
##! Original Error: Code="OnlySupportedOnUserAssignedMSICluster" Message="System-assigned managed identity not supported for custom resource.
##! Please use user-assigned managed identity."

resource "azurerm_user_assigned_identity" "aks" {
  name                = "id-${local.tags["prefix"]}-fluxcd"
  resource_group_name = azurerm_resource_group.aks.name
  location            = azurerm_resource_group.aks.location
}

data "azurerm_kubernetes_service_versions" "current" {
  location        = "West Europe"
  include_preview = true ## not recommened ## 😬
}

## FluxCD enabled Azure Kubernetes Cluster
## ? ref : https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/tutorial-use-gitops-flux2?tabs=azure-cli#for-azure-kubernetes-service-clusters

module "flux_dashboard" {
  source  = "ishuar/aks/azure"
  version = "2.2.0"


  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  name                = "${local.tags["prefix"]}-fluxcd"
  dns_prefix          = "aks-fluxcd"
  key_data            = trimspace(module.ssh_key_generator.public_ssh_key)
  kubernetes_version  = data.azurerm_kubernetes_service_versions.current.latest_version
  tags                = local.tags

  ## Identity
  identity_type = "UserAssigned"
  identity_ids  = [azurerm_user_assigned_identity.aks.id]

  ## Default node pool
  default_node_pool_name                = "system"
  default_node_pool_enable_auto_scaling = true
  default_node_pool_vm_size             = "standard_ds2_v2" ## "standard_d2ds_v5" not available in free trial azure
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
  network_policy      = "calico"
  # ebpf_data_plane     = "cilium"

  ## Azure Active Directory
  local_account_disabled           = true
  aad_rbac_enabled                 = true ## Enable the feature for Azure RBAC with AKS
  aad_rbac_managed                 = true ## Manged RBAC
  aad_azure_rbac_enabled           = true ## Azure AAD and Azure RBAC ( No K8s RBAC )
  aad_rbac_managed_admin_group_ids = [azuread_group.aks_cluster_admins.object_id]

  ## Workload Identity
  workload_identity_enabled = true
  oidc_issuer_enabled       = true

  ## Flux
  enable_fluxcd                                  = true
  fluxcd_extension_name                          = "fluxcd"
  fluxcd_configuration_name                      = "aks-project"
  fluxcd_extension_release_namespace             = "flux-system"
  fluxcd_namespace                               = local.flux_manifests_namespace ##?This Namespace should be used in k8s manifests sync with AKS fluxCD when multi tenancy is enabled.
  fluxcd_scope                                   = "cluster"
  fluxcd_git_repository_url                      = "https://github.com/ishuar/kubernetes-projects"
  fluxcd_git_repository_sync_interval_in_seconds = 60

  kustomizations = [
    {
      name                     = "sources"
      path                     = "./azure-kubernetes-service/gitops/fluxcd/sources"
      sync_interval_in_seconds = 60
    },
    {
      name                     = "secret-management"
      path                     = "./azure-kubernetes-service/gitops/fluxcd/secret-management/external-secrets-operator"
      sync_interval_in_seconds = 10
      depends_on               = ["sources"]
    },
    {
      name                     = "secrets-store"
      path                     = "./azure-kubernetes-service/gitops/fluxcd/secret-management/secrets-store"
      sync_interval_in_seconds = 10
      depends_on               = ["secret-management"]
    },
    {
      name                     = "backup-disaster-recovery"
      path                     = "./azure-kubernetes-service/gitops/fluxcd/backup-disaster-recovery/velero"
      sync_interval_in_seconds = 10
      depends_on               = ["observability"]
    },
    {
      name                     = "observability"
      path                     = "./azure-kubernetes-service/gitops/fluxcd/observability"
      sync_interval_in_seconds = 10
      depends_on               = ["secrets-store", "infrastructure"] ## secrets and cert manager crds
    },
    {
      name                     = "infrastructure"
      path                     = "./azure-kubernetes-service/gitops/fluxcd/infrastructure"
      sync_interval_in_seconds = 10
      depends_on               = ["secrets-store"] ## secrets
    },

    {
      name                     = "cluster-issuer"
      path                     = "./azure-kubernetes-service/gitops/fluxcd/cluster-issuer"
      sync_interval_in_seconds = 10
      depends_on               = ["infrastructure"] ## cert manager crds
    },
    {
      name                     = "weave-gitops-flux-ui"
      path                     = "./azure-kubernetes-service/gitops/fluxcd/weave-gitops"
      sync_interval_in_seconds = 10
      depends_on               = ["infrastructure", "observability"]
    },
  ]
  ## This is experimental only Feature
  enable_fluxcd_az_providers = true

  depends_on = [
    azapi_resource_action.container_service_provider_registration
  ]
}

## In case not able to delete aks extension.
### az k8s-extension delete  --resource-group rg-aks-module-test-euw --cluster-name minimal-example --cluster-type managedClusters --name flux-cd --force

## Assign on the resource group level for Nginx ingress controller ( vnet integration requires on subnet level )
resource "azurerm_role_assignment" "aks_mi_network_contributor" {
  scope                = azurerm_resource_group.aks.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}
