# Common
variable "environment_prefix" {
  type    = string
  default = ""
  validation {
    condition     = length(var.environment_prefix) > 0
    error_message = "The environment_prefix must be set."
  }
}

variable "ssh_private_key_internal_terraform" {
  type        = string
  default     = "../../.github/.ssh/id_rsa"
  description = "Used by terraform internally. Do not change."
}
variable "ssh_private_key_internal_ansible" {
  type        = string
  default     = "../.github/.ssh/id_rsa"
  description = "Used by terraform internally for hand over to ansible. Do not change."
}

variable "ssh_private_key_file" {
  type    = string
  default = ""
  validation {
    condition     = length(var.ssh_private_key_file) > 0
    error_message = "The ssh_private_key_file value must be a valid path. If the file does not exists it will be created."
  }
}
variable "ssh_private_key_pem" {
  type    = string
  default = ""
}
variable "azure_tags" {
  type    = map(any)
  default = {}
}

variable "azure_location" {
  type        = string
  default     = "Germany West Central"
  description = "The Azure Region in which the resources in this example should exist"
}

variable "public_hosting_domain" {
  type    = string
  default = ""
}

variable "reversproxy_dns_hostname" {
  type    = string
  default = ""
}

variable "azure_location_to_dns" {
  default = {
    "East US"                  = "eastus.cloudapp.azure.com"
    "East US 2"                = "eastus2.cloudapp.azure.com"
    "South Central US"         = "southcentralus.cloudapp.azure.com"
    "West US 2"                = "westus2.cloudapp.azure.com"
    "West US 3"                = "westus3.cloudapp.azure.com"
    "Australia East"           = "australiaeast.cloudapp.azure.com"
    "Southeast Asia"           = "southeastasia.cloudapp.azure.com"
    "North Europe"             = "northeurope.cloudapp.azure.com"
    "Sweden Central"           = "swedencentral.cloudapp.azure.com"
    "UK South"                 = "uksouth.cloudapp.azure.com"
    "West Europe"              = "westeurope.cloudapp.azure.com"
    "Central US"               = "centralus.cloudapp.azure.com"
    "North Central US"         = "northcentralus.cloudapp.azure.com"
    "West US"                  = "westus.cloudapp.azure.com"
    "South Africa North"       = "southafricanorth.cloudapp.azure.com"
    "Central India"            = "centralindia.cloudapp.azure.com"
    "East Asia"                = "eastasia.cloudapp.azure.com"
    "Japan East"               = "japaneast.cloudapp.azure.com"
    "Jio India West"           = "jioindiawest.cloudapp.azure.com"
    "Korea Central"            = "koreacentral.cloudapp.azure.com"
    "Canada Central"           = "canadacentral.cloudapp.azure.com"
    "France Central"           = "francecentral.cloudapp.azure.com"
    "Germany West Central"     = "germanywestcentral.cloudapp.azure.com"
    "Norway East"              = "norwayeast.cloudapp.azure.com"
    "Switzerland North"        = "switzerlandnorth.cloudapp.azure.com"
    "UAE North"                = "uaenorth.cloudapp.azure.com"
    "Brazil South"             = "brazilsouth.cloudapp.azure.com"
    "Central US (Stage)"       = "centralusstage.cloudapp.azure.com"
    "East US (Stage)"          = "eastusstage.cloudapp.azure.com"
    "East US 2 (Stage)"        = "eastus2stage.cloudapp.azure.com"
    "North Central US (Stage)" = "northcentralusstage.cloudapp.azure.com"
    "South Central US (Stage)" = "southcentralusstage.cloudapp.azure.com"
    "West US (Stage)"          = "westusstage.cloudapp.azure.com"
    "West US 2 (Stage)"        = "westus2stage.cloudapp.azure.com"
    "Asia"                     = "asia.cloudapp.azure.com"
    "Asia Pacific"             = "asiapacific.cloudapp.azure.com"
    "Australia"                = "australia.cloudapp.azure.com"
    "Brazil"                   = "brazil.cloudapp.azure.com"
    "Canada"                   = "canada.cloudapp.azure.com"
    "Europe"                   = "europe.cloudapp.azure.com"
    "France"                   = "france.cloudapp.azure.com"
    "Germany"                  = "germany.cloudapp.azure.com"
    "Global"                   = "global.cloudapp.azure.com"
    "India"                    = "india.cloudapp.azure.com"
    "Japan"                    = "japan.cloudapp.azure.com"
    "Korea"                    = "korea.cloudapp.azure.com"
    "Norway"                   = "norway.cloudapp.azure.com"
    "South Africa"             = "southafrica.cloudapp.azure.com"
    "Switzerland"              = "switzerland.cloudapp.azure.com"
    "United Arab Emirates"     = "uae.cloudapp.azure.com"
    "United Kingdom"           = "uk.cloudapp.azure.com"
    "United States"            = "unitedstates.cloudapp.azure.com"
    "East Asia (Stage)"        = "eastasiastage.cloudapp.azure.com"
    "Southeast Asia (Stage)"   = "southeastasiastage.cloudapp.azure.com"
    "Central US EUAP"          = "centraluseuap.cloudapp.azure.com"
    "East US 2 EUAP"           = "eastus2euap.cloudapp.azure.com"
    "West Central US"          = "westcentralus.cloudapp.azure.com"
    "South Africa West"        = "southafricawest.cloudapp.azure.com"
    "Australia Central"        = "australiacentral.cloudapp.azure.com"
    "Australia Central 2"      = "australiacentral2.cloudapp.azure.com"
    "Australia Southeast"      = "australiasoutheast.cloudapp.azure.com"
    "Japan West"               = "japanwest.cloudapp.azure.com"
    "Jio India Central"        = "jioindiacentral.cloudapp.azure.com"
    "Korea South"              = "koreasouth.cloudapp.azure.com"
    "South India"              = "southindia.cloudapp.azure.com"
    "West India"               = "westindia.cloudapp.azure.com"
    "Canada East"              = "canadaeast.cloudapp.azure.com"
    "France South"             = "francesouth.cloudapp.azure.com"
    "Germany North"            = "germanynorth.cloudapp.azure.com"
    "Norway West"              = "norwaywest.cloudapp.azure.com"
    "Switzerland West"         = "switzerlandwest.cloudapp.azure.com"
    "UK West"                  = "ukwest.cloudapp.azure.com"
    "UAE Central"              = "uaecentral.cloudapp.azure.com"
    "Brazil Southeast"         = "brazilsoutheast.cloudapp.azure.com"
  }
}

variable "azure_resource_group_postfix" {
  type    = string
  default = "demo"
}

# AD Domain

variable "ad_domain_name" {
  type    = string
  default = ""
}
variable "ad_domain_netbios_name" {
  type    = string
  default = ""
}
variable "ad_domain_dn_name" {
  type    = string
  default = ""
}

# Network

variable "azure_virtual_network_address_space" {
  type    = string
  default = "10.0.0.0/16"
}

variable "azure_virual_network_subnet_address_prefixes" {
  type    = list(string)
  default = ["10.0.1.0/24"]
}

variable "azure_virtual_network_subnet_names" {
  type        = list(string)
  description = "The name of the virtual network's subnet"
  default     = ["frontend"]
}
variable "azure_virtual_network_dns_servers" {
  type    = list(string)
  default = []
}

variable "azure_route_table_disable_bgp_route_propagation" {
  type    = bool
  default = false
}

# Storage

variable "azure_storage_account_name" {
  type    = string
  default = ""
}

# Storage Shares

variable "azure_storage_shares_storage_account_name" {
  type    = string
  default = ""
}

variable "default_share_permission" {
  type        = string
  default     = "StorageFileDataSmbShareElevatedContributor" # None|StorageFileDataSmbShareContributor|StorageFileDataSmbShareReader|StorageFileDataSmbShareElevatedContributor
  description = "Share-level permissions for all authenticated identities https://docs.microsoft.com/en-us/azure/storage/files/storage-files-identity-ad-ds-assign-permissions?tabs=azure-powershell#share-level-permissions-for-all-authenticated-identities"
}

variable "storage_shares_principal_names" {
  type    = list(string)
  default = []
}

variable "storage_shares" {
  type = list(object({
    name  = string,
    quota = number,
    rbacs = list(object(
      { role = string, principal_name = string }
    ))
  }))
  default = [
    {
      name  = "officecontainer",
      quota = 50,
      rbacs = []
    },
    {
      name  = "profilecontainer",
      quota = 50,
      rbacs = []
    },
    {
      name  = "stuff",
      quota = 50,
      rbacs = []
    }
  ]
}

# VM

variable "azure_vm_admin_username" {
  type      = string
  default   = ""
  sensitive = true
}
variable "azure_vm_admin_password" {
  type      = string
  default   = ""
  sensitive = true
}
variable "azure_vm_windows_timezone" {
  type    = string
  default = "UTC"
}
variable "azure_vm_windows_user_language" {
  type    = string
  default = "en-US"
}

variable "azure_bootstrap_resource_group_name" {
  type    = string
  default = ""
}

variable "azure_bootstrap_storage_account_name" {
  type    = string
  default = ""
}

variable "azure_bootstrap_storage_account_container_name" {
  type    = string
  default = ""
}

variable "generated_for_ansible_file_prefix" {
  type    = string
  default = "tf_gen_"
}
