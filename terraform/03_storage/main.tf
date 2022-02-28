data "azurerm_resource_group" "storage" {
  name = "rg-${var.environment_prefix}-${var.azure_resource_group_postfix}"
}

resource "azurerm_storage_account" "storage" {
  name                     = var.azure_storage_account_name
  resource_group_name      = data.azurerm_resource_group.storage.name
  location                 = data.azurerm_resource_group.storage.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2" # BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2
  access_tier              = "Hot"       # Hot and Cool
  tags = merge(
    {
      "resourcename" = format("%s", lower(replace(var.azure_storage_account_name, "/[[:^alnum:]]/", ""))),
      "environment"  = var.environment_prefix
    },
    var.azure_tags
  )
}

output "primary_blob_endpoint" {
  value = azurerm_storage_account.storage.primary_blob_endpoint
}

output "name" {
  value = azurerm_storage_account.storage.name
}
