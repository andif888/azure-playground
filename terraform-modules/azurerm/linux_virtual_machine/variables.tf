# Azure VM

variable "tags" {
  description = "The tags to associate with your network and subnets."
  type        = map(string)
  default     = {}
}

variable "admin_username" {
  type      = string
  default   = ""
  sensitive = true
}

variable "admin_password" {
  type      = string
  default   = ""
  sensitive = true
}

variable "name" {
  type    = string
  default = ""
}

variable "hostname" {
  type    = string
  default = ""
}

variable "instance_count" {
  type    = number
  default = 1
}

variable "size" {
  type    = string
  default = "Standard_D2ds_v5"
}

variable "license_type" {
  type        = string
  default     = "None"
  description = "(Optional) Specifies the BYOL Type for this Virtual Machine. This is only applicable to Windows Virtual Machines. Possible values are Windows_Client and Windows_Server"
}

variable "resource_group_name" {
  # (must) staging != producion
  type        = string
  description = "The Azure Resource Group"
  default     = ""
}

variable "virtual_network_resource_group_name" {
  type    = string
  default = ""
}

variable "virtual_network_name" {
  # (should) staging != producion
  type        = string
  description = "The name of the virtual network"
  default     = ""
}
variable "virtual_network_subnet_name" {
  # (can) staging == producion
  type        = string
  description = "The name of the virtual network's subnet"
  default     = ""
}

variable "enable_accelerated_networking" {
  type        = bool
  description = "(Optional) Enable accelerated networking on Network interface."
  default     = false
}

variable "enable_ip_forwarding" {
  type        = bool
  description = "(Optional) Should IP Forwarding be enabled? Defaults to false"
  default     = false
}

variable "private_ip_address_start" {
  type    = number
  default = 6
}

variable "private_ip_address_allocation" {
  type    = string
  default = "Dynamic"
}

variable "public_ip" {
  type    = bool
  default = false
}
variable "public_ip_dns" {
  type    = string
  default = ""
}
variable "public_ip_allocation_method" {
  type    = string
  default = "Dynamic"
}

variable "nsg_allowed_ports" {
  default = []
}

variable "nsg_source_address_prefixes" {
  description = "(Optional) List of source address prefixes allowed to access var.remote_port."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "os_disk_storage_account_type" {
  type    = string
  default = "Standard_LRS"
}
variable "os_disk_caching" {
  type    = string
  default = "ReadWrite"
}
variable "os_disk_ephemeral" {
  type    = bool
  default = false
}
variable "os_disk_size_gb" {
  type    = number
  default = null
}

variable "data_disk_size_gb" {
  type    = number
  default = null
}
variable "data_disk_storage_account_type" {
  type    = string
  default = "Standard_LRS"
}
variable "data_disk_create_option" {
  type    = string
  default = "Empty"
}
variable "data_disk_caching" {
  type    = string
  default = "ReadWrite"
}



variable "source_image_reference_publisher" {
  type    = string
  default = ""
}

variable "source_image_reference_offer" {
  type    = string
  default = ""
}

variable "source_image_reference_sku" {
  type    = string
  default = ""
}

variable "source_image_reference_version" {
  type    = string
  default = "latest"
}

variable "public_key_openssh" {
  type    = string
  default = ""
}

variable "timezone" {
  type    = string
  default = ""
}
