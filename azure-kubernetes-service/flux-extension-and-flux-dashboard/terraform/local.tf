locals {
  tags = {
    github_repo     = "kubernetes-projects"
    managed_by      = "terraform"
    directory_level = "azure-kubernetes-service/private-docker-registry"
  }
  flux_manifests_namespace = "flux"
  service_principals       = ["flux-dashboard-oidc"]
}
