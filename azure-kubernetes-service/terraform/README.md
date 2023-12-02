## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | ~>1.8 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.55 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | 1.10.0 |
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | 2.46.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.82.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.5.1 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_flux_dashboard"></a> [flux\_dashboard](#module\_flux\_dashboard) | ishuar/aks/azure | 2.2.0 |
| <a name="module_ssh_key_generator"></a> [ssh\_key\_generator](#module\_ssh\_key\_generator) | github.com/ishuar/terraform-sshkey-generator | v1.1.0 |

## Resources

| Name | Type |
|------|------|
| [azapi_resource_action.container_service_provider_registration](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource_action) | resource |
| [azuread_app_role_assignment.flux_dashboard](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/app_role_assignment) | resource |
| [azuread_application.flux_dashboard](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application) | resource |
| [azuread_group.aks_cluster_admins](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group) | resource |
| [azuread_service_principal.flux_dashboard](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal) | resource |
| [azuread_service_principal_password.flux_dashboard](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal_password) | resource |
| [azurerm_dns_zone.k8s_learndevops_in](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_zone) | resource |
| [azurerm_federated_identity_credential.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/federated_identity_credential) | resource |
| [azurerm_key_vault.k8s_flux](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |
| [azurerm_key_vault_secret.flux_dashboard_client_id](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.flux_dashboard_client_secret](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.subscription_and_tenant_id](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_resource_group.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_role_assignment.aks_mi_network_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.dns_admin](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.kv_rbac](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_subnet.aks_api](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.aks_node](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_user_assigned_identity.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_user_assigned_identity.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_virtual_network.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [random_password.grafana_admin_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_uuid.flux_aad_app](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) | resource |
| [terraform_data.az_feature_register](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_kubernetes_service_versions.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/kubernetes_service_versions) | data source |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ALERTMANAGER_DISCORD_CHANNEL_RECEIVER_URL"></a> [ALERTMANAGER\_DISCORD\_CHANNEL\_RECEIVER\_URL](#input\_ALERTMANAGER\_DISCORD\_CHANNEL\_RECEIVER\_URL) | (optional) Discord channel URL used as alert manager receiver for kube-prom-stack. Which is further set up as a secret and mounted to alertmanager pod | `string` | `"FROM_AUTO_TFVARS_FILE"` | no |
| <a name="input_secret_management_key_vault_name"></a> [secret\_management\_key\_vault\_name](#input\_secret\_management\_key\_vault\_name) | (optional) Key vault used for kubernetes secret management with external secrets operator. | `string` | `"k8s-projects-secrets-02"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dns_zone_name_servers"></a> [dns\_zone\_name\_servers](#output\_dns\_zone\_name\_servers) | List of DNS nameservers to which domain registrar has to delegate DNS traffic. e.g from Godady to azure public DNS zone. |
| <a name="output_flux_dashboard_client_id_name"></a> [flux\_dashboard\_client\_id\_name](#output\_flux\_dashboard\_client\_id\_name) | Client ID used for flux dashboard ( weave gitops ) service principal. |
| <a name="output_flux_dashboard_client_secret_name"></a> [flux\_dashboard\_client\_secret\_name](#output\_flux\_dashboard\_client\_secret\_name) | Client secret used for flux dashboard ( weave gitops ) service principal. |
| <a name="output_name_client_id_key_pair"></a> [name\_client\_id\_key\_pair](#output\_name\_client\_id\_key\_pair) | clientID for the managed identities in the format 'name = client\_id' for usage in kubernetes manifests without accessing portal. |
| <a name="output_subscription_id"></a> [subscription\_id](#output\_subscription\_id) | Subscription ID in which infrastrucutre is deployed. |
| <a name="output_tenant_id"></a> [tenant\_id](#output\_tenant\_id) | Tenant ID in which infrastructure is deployed. |
