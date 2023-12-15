locals {
  tags = {
    prefix          = "kubernetes-projects"
    managed_by      = "terraform"
    directory_level = "azure-kubernetes-service/terraform"
    gitops_operator = "fluxcd"
    environment     = "dev"
    cost_center     = "123456"
    github_repo     = "ishuar/kubernetes-in-real-life"
  }
  flux_manifests_namespace = "flux"
  key_vault_access         = ["external-secrets-operator"]
  dns_admin_access         = ["external-dns", "cert-manager"]
  storage_admin            = ["velero"]
}
