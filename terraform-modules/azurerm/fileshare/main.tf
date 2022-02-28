data "azurerm_resource_group" "network" {
  name = var.network_rules_virtual_network_subnet[0].resource_group_name
}

data "azurerm_subnet" "network_rules" {
  count                = length(var.network_rules_virtual_network_subnet)
  name                 = var.network_rules_virtual_network_subnet[count.index].subnet_name
  virtual_network_name = var.network_rules_virtual_network_subnet[count.index].virtual_network_name
  resource_group_name  = var.network_rules_virtual_network_subnet[count.index].resource_group_name
}

resource "azurerm_storage_account" "fileshare" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
  account_kind             = var.account_kind
  access_tier              = var.access_tier
  min_tls_version          = var.min_tls_version
  tags                     = merge({ "resourcename" = format("%s", lower(replace(var.storage_account_name, "/[[:^alnum:]]/", ""))) }, var.tags, )

  network_rules {
    default_action             = var.network_rules_default_action
    bypass                     = var.network_rules_bypass
    ip_rules                   = var.network_rules_ip_rules
    virtual_network_subnet_ids = data.azurerm_subnet.network_rules.*.id
  }

  share_properties {
    retention_policy {
      days = 7
    }
    smb {
      versions = ["SMB3.0", "SMB3.1.1"]
      authentication_types = ["NTLMv2", "Kerberos"]
      kerberos_ticket_encryption_type = ["RC4-HMAC", "AES-256"]
      channel_encryption_type = ["AES-128-CCM", "AES-128-GCM", "AES-256-GCM"]
    }
  }

  dynamic "azure_files_authentication" {
    for_each = var.azure_files_authentication == null ? [] : [1]

    content {
      directory_type = var.azure_files_authentication.directory_type

      dynamic "active_directory" {
        for_each = lookup(var.azure_files_authentication, "active_directory", false) == false ? [] : [1]

        content {
          domain_guid         = var.azure_files_authentication.active_directory.domain_guid # AD Attribute: domain objectGUID
          domain_name         = var.azure_files_authentication.active_directory.domain_name
          domain_sid          = var.azure_files_authentication.active_directory.domain_sid # AD Attribute: domain objectSID
          forest_name         = var.azure_files_authentication.active_directory.forest_name
          netbios_domain_name = var.azure_files_authentication.active_directory.netbios_domain_name
          storage_sid         = var.azure_files_authentication.active_directory.storage_sid

        }
      }
    }
  }
}

locals {
  storage_share_rbac_config = [
    for share in var.storage_shares : [
      for rbac in share.rbacs : {
        key            = "${share.name}${rbac.role}${rbac.principal_name}"
        share_name     = share.name
        role           = rbac.role
        principal_name = rbac.principal_name
      }
    ]
  ]
}

locals {
  local_share_rbacs = flatten(local.storage_share_rbac_config)
}

resource "azurerm_storage_share" "fileshare" {
  for_each = { for share in var.storage_shares : share.name => share }

  name                 = each.value.name
  storage_account_name = azurerm_storage_account.fileshare.name
  quota                = each.value.quota

  depends_on = [azurerm_storage_account.fileshare]
}

data "azuread_group" "fileshare" {
  for_each = { for rbac in var.storage_shares_principal_names : rbac => rbac }

  display_name     = each.key
  security_enabled = true
}

resource "azurerm_role_assignment" "fileshare" {
  for_each = { for rbac in local.local_share_rbacs : rbac.key => rbac }

  scope = azurerm_storage_share.fileshare[each.value.share_name].resource_manager_id
  # role_definition_id = data.azurerm_role_definition.fileshare[count.index].id
  role_definition_name = each.value.role
  principal_id         = data.azuread_group.fileshare[each.value.principal_name].object_id

  depends_on = [azurerm_storage_share.fileshare]
}

resource "azurerm_private_endpoint" "fileshare" {
  count               = var.private_endpoint_name != "" ? 1 : 0
  name                = var.private_endpoint_name
  location            = data.azurerm_resource_group.network.location
  resource_group_name = data.azurerm_resource_group.network.name
  subnet_id           = data.azurerm_subnet.network_rules[0].id

  private_service_connection {
    name                           = var.private_endpoint_name
    private_connection_resource_id = azurerm_storage_account.fileshare.id
    is_manual_connection           = false
    subresource_names              = ["file"]
  }

  tags = merge({ "resourcename" = format("%s", lower(replace(var.private_endpoint_name, "/[[:^alnum:]]/", ""))) }, var.tags, )

  depends_on = [azurerm_storage_share.fileshare]
}

# https://docs.microsoft.com/en-us/azure/storage/files/storage-files-identity-ad-ds-enable
