variable "tags" {
  description = "The tags to associate with your network and subnets."
  type        = map(string)

  default = {}
}

variable "location" {
  type        = string
  default     = ""
  description = "(Required) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
}
variable "resource_group_name" {
  type        = string
  description = "The Azure Resource Group"
  default     = " (Optional) The name of the resource group in which to create the storage account. Changing this forces a new resource to be created."
}

variable "storage_account_name" {
  type        = string
  default     = ""
  description = "(Required) Specifies the name of the storage account. Changing this forces a new resource to be created. This must be unique across the entire Azure service, not just within the resource group"
}
variable "account_tier" {
  type        = string
  default     = "Standard"
  description = "(Required) Defines the Tier to use for this storage account. Valid options are Standard and Premium. For BlockBlobStorage and FileStorage accounts only Premium is valid. Changing this forces a new resource to be created."
}
variable "account_replication_type" {
  type        = string
  default     = "LRS"
  description = "(Required) Defines the type of replication to use for this storage account. Valid options are LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS. Changing this forces a new resource to be created when types LRS, GRS and RAGRS are changed to ZRS, GZRS or RAGZRS and vice versa"
}
variable "account_kind" {
  type        = string
  default     = "StorageV2"
  description = " (Optional) Defines the Kind of account. Valid options are BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2. Changing this forces a new resource to be created. Defaults to StorageV2."
}
variable "access_tier" {
  type        = string
  default     = " Hot"
  description = "(Optional) Defines the access tier for BlobStorage, FileStorage and StorageV2 accounts. Valid options are Hot and Cool, defaults to Hot."
}
variable "network_rules_default_action" {
  type        = string
  default     = "Allow"
  description = "(Required) Specifies the default action of allow or deny when no other rules match. Valid options are Deny or Allow."
}
variable "network_rules_bypass" {
  type        = list(string)
  default     = ["AzureServices"]
  description = "(Optional) Specifies whether traffic is bypassed for Logging/Metrics/AzureServices. Valid options are any combination of Logging, Metrics, AzureServices, or None."
}
variable "network_rules_ip_rules" {
  type        = list(string)
  default     = []
  description = "(Optional) List of public IP or IP ranges in CIDR Format. Only IPV4 addresses are allowed. Private IP address ranges (as defined in RFC 1918) are not allowed."
}
variable "network_rules_virtual_network_subnet" {
  type = list(object({
    subnet_name          = string,
    virtual_network_name = string,
    resource_group_name  = string
  }))
  default     = []
  description = "(Optional) A list of resource ids for subnets."
}
variable "azure_files_authentication" {
  type = object({
    directory_type = string,
    active_directory = object({
      domain_guid         = string,
      domain_name         = string,
      domain_sid          = string,
      forest_name         = string,
      netbios_domain_name = string,
      storage_sid         = string
    })
  })
  default = null
}
variable "private_endpoint_name" {
  type        = string
  default     = ""
  description = "(Required) Specifies the Name of the Private Service Connection. Changing this forces a new resource to be created."
}
variable "storage_shares" {
  type = list(object({
    name  = string,
    quota = number,
    rbacs = list(object(
      { role = string, principal_name = string }
    ))
  }))
  default = []
}
variable "storage_shares_principal_names" {
  type    = list(string)
  default = []
}
variable "min_tls_version" {
  type        = string
  default     = "TLS1_0"
  description = "(Optional) The minimum supported TLS version for the storage account. Possible values are TLS1_0, TLS1_1, and TLS1_2. Defaults to TLS1_0 for new storage accounts."
}
