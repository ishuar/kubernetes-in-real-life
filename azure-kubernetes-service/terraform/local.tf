locals {
  tags = {
    github_repo     = "kubernetes-projects"
    managed_by      = "terraform"
    directory_level = "azure-kubernetes-service/terraform"
    gitops_operator = "fluxcd"
  }
  flux_manifests_namespace = "flux"
  key_vault_access         = ["external-secrets-operator"]
  dns_admin_access         = ["external-dns", "cert-manager"]
  storage_admin            = ["velero"]
}
