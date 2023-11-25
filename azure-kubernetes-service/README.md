- [Azure Kubernetes Service (AKS) Overview](#azure-kubernetes-service-aks-overview)
  - [Directory Structure](#directory-structure)
    - [terraform](#terraform)
      - [File Explanations:](#file-explanations)
    - [gitops](#gitops)
    - [scripts](#scripts)

# Azure Kubernetes Service (AKS) Overview

This directory focuses on [Azure Kubernetes Services (AKS)](https://learn.microsoft.com/en-us/azure/aks/intro-kubernetes). The AKS cluster is deployed using infrastructure as code with [`terraform`](https://www.terraform.io/).

## Directory Structure

### terraform

This directory contains the configuration for deploying the Azure Kubernetes Service cluster and its dependencies. Considering workload identity, secret management, and single sign-on configurations, additional resources are also created.

#### File Explanations:

- `backend.tf`: Configuration for Terraform remote state. More details on remote state [here](https://developer.hashicorp.com/terraform/language/state/remote).

- `azapi.tf`: Configuration for registering required Azure providers and respective features as per the AKS configuration.

- `key-vault-and-secrets`: Configuration for Azure Key Vault and secrets created within it for future secret management using `external-secrets-operator`.

- `main.tf`: Configuration for the deployment of Azure Kubernetes cluster and closely coupled resources. The public Terraform module [ishuar/aks](https://registry.terraform.io/modules/ishuar/aks/azure/latest) has been used to simplify deployment.

- `network.tf`: Configuration for underlying network infrastructure.

- `service-principals.tf`: Configuration for service principal used for OIDC-based login for future Kubernetes workloads.

- `workload-identities.tf`: Configuration for workload identities for Kubernetes workloads to avoid long-term identities and follow the least privilege access concepts. More details on Azure workload identities [here](https://azure.github.io/azure-workload-identity/docs/quick-start.html).

- `variables.tf`, `versions.tf`, and `outputs.tf`: Configurations for Terraform variables, Terraform/provider versions, and Terraform outputs exposed, respectively.

### gitops

This directory serves as the gateway to implementing GitOps for Azure Kubernetes Service (AKS) deployments. Flux v2 is enabled as a cluster extension in Azure Arc-enabled Kubernetes clusters or Azure Kubernetes Service (AKS) clusters. This allows you to declaratively manage your Kubernetes applications through Git repositories without manual installation of fluxcd.

For more details, refer to the [GitOps README](./gitops/fluxcd/README.md).

### scripts

This directory provides `bash scripts` to automate tasks required for Terraform and Azure Kubernetes cluster configurations.
