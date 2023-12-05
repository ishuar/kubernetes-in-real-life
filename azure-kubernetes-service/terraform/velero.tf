resource "azurerm_resource_group" "velero" {
  name     = "rg-velero-backup-${local.tags["github_repo"]}"
  location = "West Europe"
  tags     = local.tags
}

resource "azurerm_storage_account" "velero" {
  name                      = "stgvelerowu001"
  resource_group_name       = azurerm_resource_group.velero.name
  location                  = azurerm_resource_group.velero.location
  account_tier              = "Standard"
  account_replication_type  = "ZRS"
  min_tls_version           = "TLS1_2"
  enable_https_traffic_only = true
  tags                      = local.tags
}

resource "azurerm_storage_container" "velero" {
  name                  = "velero"
  storage_account_name  = azurerm_storage_account.velero.name
  container_access_type = "private"
}

resource "azurerm_role_definition" "velero" {
  name        = "velero-role-aks"
  scope       = data.azurerm_subscription.current.id
  description = "Role Required for velero to manage snapshots, backups and restores."

  permissions {
    actions = [
      "Microsoft.Compute/disks/read",
      "Microsoft.Compute/disks/write",
      "Microsoft.Compute/disks/endGetAccess/action",
      "Microsoft.Compute/disks/beginGetAccess/action",
      "Microsoft.Compute/snapshots/read",
      "Microsoft.Compute/snapshots/write",
      "Microsoft.Compute/snapshots/delete",
      "Microsoft.Storage/storageAccounts/listkeys/action",
      "Microsoft.Storage/storageAccounts/regeneratekey/action",
      "Microsoft.Storage/storageAccounts/blobServices/containers/delete",
      "Microsoft.Storage/storageAccounts/blobServices/containers/read",
      "Microsoft.Storage/storageAccounts/blobServices/containers/write",
      "Microsoft.Storage/storageAccounts/blobServices/generateUserDelegationKey/action"
    ]
    data_actions = [
      "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/delete",
      "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read",
      "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/write",
      "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/move/action",
      "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/add/action"
    ]
  }

  assignable_scopes = [
    data.azurerm_subscription.current.id,
  ]
}
## Worlload Identity Created in the worlload-identities.t file
resource "azurerm_role_assignment" "storage_admin" {
  for_each = toset(local.storage_admin)

  scope                = data.azurerm_subscription.current.id
  role_definition_name = azurerm_role_definition.velero.name
  principal_id         = azurerm_user_assigned_identity.this[each.value].principal_id
}
