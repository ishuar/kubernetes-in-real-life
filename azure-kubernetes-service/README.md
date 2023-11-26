- [Azure Kubernetes Service (AKS) Overview](#azure-kubernetes-service-aks-overview)
  - [Directory Structure](#directory-structure)
    - [terraform](#terraform)
      - [File Explanations:](#file-explanations)
    - [gitops](#gitops)
    - [scripts](#scripts)
  - [Resources Provisioning](#resources-provisioning)
    - [Prerequisites](#prerequisites)
    - [Terraform Execution](#terraform-execution)
      - [Sign into Azure Account](#sign-into-azure-account)
      - [Backend configuration](#backend-configuration)
        - [Create infrastructure required for remote backend](#create-infrastructure-required-for-remote-backend)
        - [Configure Terraform azurerm backend](#configure-terraform-azurerm-backend)
      - [Terraform Plan](#terraform-plan)
      - [Terraform Apply](#terraform-apply)
      - [Destroy the Infrastructure](#destroy-the-infrastructure)


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


## Resources Provisioning

The azure kubernetes cluster , dependencies , fluxcd and the kubernetes applications can be deployed via `terraform`.

### Prerequisites

In order to re-use the configurations please check the below tool matrix:

| Name          | Version Used | Help                                                                                                 | Required |
|---------------|--------------|------------------------------------------------------------------------------------------------------|----------|
| Terraform     | `>= 1.1.0`   | [Install Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) | Yes      |
| azure-cli     | `2.50.0`     | [Install azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)                   | Yes      |
| homebrew      | `4.1.3`      | [Homebrew Installation](https://docs.brew.sh/Installation)                                           | No       |
| Azure Account | `N/A`        | [Create Azure account](https://azure.microsoft.com/en-us/free)                                       | yes      |
| flux-cli      | `2.1.2`      | [Install Flux CLI](https://fluxcd.io/flux/cmd/)                                                      | No       |


If you have `homebrew` installed , all tools can be installed with command `brew install <Name>`, except Azure Account 😁. Flux CLI is only needed to support troubleshooting.

### Terraform Execution


Few key notes:

1. This Guide is created for someone to replicate the infrastructre provisioning from their local machine standpoint.
2. In order to follow this guide , it is assumed that this repostory is forked and the same folder structure is available on the end user machine. Further guide context is from the `azure-kubernetes-service/terraform` directory.

#### Sign into Azure Account

We can use any appropriate method to authenticate to azure resource manager, in this guide we will utilise the `az login`

1. Run `az login` command

If the CLI can open your default browser, it initiates authorization code flow and open the default browser to load an Azure sign-in page.
Otherwise, it initiates the device code flow and tell you to open a browser page at https://aka.ms/devicelogin and enter the code displayed in your terminal.
If no web browser is available or the web browser fails to open, you may force device code flow with az login --use-device-code.

2. Sign in with your account credentials in the browser.

#### Backend configuration

Its a best practice to use  [remote](https://developer.hashicorp.com/terraform/language/settings/backends/remote) backends for terraform, in this guide we are using specifically [azurerm](https://developer.hashicorp.com/terraform/language/settings/backends/azurerm) remote backend. Kindly refer to [Example Configuration
](https://developer.hashicorp.com/terraform/language/settings/backends/azurerm#example-configuration) for more details on its configuration.

##### Create infrastructure required for remote backend

Use below command to create [`Resource Group`](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal#what-is-a-resource-group), [`Storage Account`](https://learn.microsoft.com/en-us/azure/storage/common/storage-account-overview), and [`Container`](https://learn.microsoft.com/en-us/azure/storage/blobs/storage-blobs-overview)

```bash
## Run script from azure-kubernetes-service/terraform directory reference.
../scripts/create-tf-backend.sh <YOUR_UNIQUE_STORAGE_ACCOUNT_NAME>
```

>**IMPORTANT:** ⚠️ Please set first positional argument to script for `STORAGE_ACCOUNT_NAME` to over-ride the default name used in script, as the storage account names are **globally** unique.


##### Configure Terraform azurerm backend

In the [backend.tf](./terraform/backend.tf) adjust the below parameters

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-kubernetes-projects-backend" ## Optional, if over-ride by env var in step Create infrastructure required for remote backend
    storage_account_name = "STORAGE_ACCOUNT_NAME"           ## Required, set STORAGE_ACCOUNT_NAME as positional argument to script.
    container_name       = "tfstate"                        ## Optional, if over-ride by env var in step Create infrastructure required for remote backend
    key                  = "kubernetes-projects"            ## Optional, if over-ride by env var in step Create infrastructure required for remote backend
  }
}
```

#### Terraform Plan

Once the backend configuration is set up, we can start with terraform actions. Plan is generally optional in local workflows however a good practice for dry-run configurations.

- Use below commands to generate the terraform plan.

```bash
terraform init
terraform plan
```

#### Terraform Apply

Once we are satisfied with the plan, configurations can be applied to provison the infrastructure.

- Use below command to apply the configuration.

```bash
terraform apply -auto-approve
```

#### Destroy the Infrastructure

Once you are done with your testing or want to de-provision the infrastructure. The entire infrastrucutre can be deleted with the below command.

```bash
terraform destroy
```

> The resources provisioned in this set us generates costs, please destroy infrastrucutre to avoid extra costs.

More details on [terraform-dir0readme](./terraform/README.md)
