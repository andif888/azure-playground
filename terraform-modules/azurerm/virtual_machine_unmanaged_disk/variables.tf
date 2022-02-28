variable "resource_group_name" {
  description = "The name of the resource group in which the resources will be created."
  type        = string
}

variable "location" {
  description = "(Optional) The location in which the resources will be created."
  type        = string
  default     = ""
}

variable "name" {
  type    = string
  default = ""
}

variable "proximity_placement_group_name" {
  type    = string
  default = ""
}

variable "virtual_network_subnet_id" {
  description = "The subnet id of the virtual network where the virtual machines will reside."
  type        = string
}

variable "virtual_network_subnet_name" {}
variable "virtual_network_name" {}
variable "private_ip_address_start" {
  default = 6
}
variable "private_ip_address_allocation" {
  default = "Dynamic"
}

variable "nsg_allowed_ports" {
  default = []
}

variable "public_ip" {
  description = "if public IP to assign"
  type        = bool
  default     = false
}

variable "allocation_method" {
  description = "Defines how an IP address is assigned. Options are Static or Dynamic."
  type        = string
  default     = "Dynamic"
}

variable "public_ip_dns" {
  description = "Optional globally unique per datacenter region domain name label to apply to each public ip address. e.g. thisvar.varlocation.cloudapp.azure.com where you specify only thisvar here. This is an array of names which will pair up sequentially to the number of public ips defined in var.nb_public_ip. One name or empty string is required for every public ip. If no public ip is desired, then set this to an array with a single empty string."
  type        = string
  default     = ""
}
variable "public_ip_dns_no_index" {
  type        = bool
  default     = false
}

variable "admin_password" {
  description = "The admin password to be used on the VMSS that will be deployed. The password must meet the complexity requirements of Azure."
  type        = string
  default     = ""
  sensitive   = true
}

variable "public_key_openssh" {
  description = "public ssh key in openssh format"
  type        = string
  default     = ""
}

variable "admin_username" {
  description = "The admin username of the VM that will be deployed."
  type        = string
  default     = ""
  sensitive   = true
}

variable "disable_password_authentication" {
  description = "(Optional) disables password athentication"
  type        = bool
  default     = false
}

variable "custom_data" {
  description = "The custom data to supply to the machine. This can be used as a cloud-init for Linux systems."
  type        = string
  default     = ""
}

variable "windows_unattend_firstlogon_xml" {
  type    = string
  default = ""
}

variable "size" {
  description = "Specifies the size of the virtual machine."
  type        = string
  default     = "Standard_D2s_v3"
}

variable "instance_count" {
  description = "Specify the number of vm instances."
  type        = number
  default     = 1
}

variable "hostname" {
  description = "local name of the Virtual Machine."
  type        = string
  default     = "myvm"
}

variable "vm_os_simple" {
  description = "Specify UbuntuServer, WindowsServer, RHEL, openSUSE-Leap, CentOS, Debian, CoreOS and SLES to get the latest image version of the specified os.  Do not provide this value if a custom value is used for vm_os_publisher, vm_os_offer, and vm_os_sku."
  type        = string
  default     = ""
}

variable "vm_os_id" {
  description = "The resource ID of the image that you want to deploy if you are using a custom image.Note, need to provide is_windows_image = true for windows custom images."
  type        = string
  default     = ""
}

variable "is_windows_image" {
  description = "Boolean flag to notify when the custom image is windows based."
  type        = bool
  default     = false
}

variable "vm_os_publisher" {
  description = "The name of the publisher of the image that you want to deploy. This is ignored when vm_os_id or vm_os_simple are provided."
  type        = string
  default     = ""
}

variable "vm_os_offer" {
  description = "The name of the offer of the image that you want to deploy. This is ignored when vm_os_id or vm_os_simple are provided."
  type        = string
  default     = ""
}

variable "vm_os_sku" {
  description = "The sku of the image that you want to deploy. This is ignored when vm_os_id or vm_os_simple are provided."
  type        = string
  default     = ""
}

variable "vm_os_version" {
  description = "The version of the image that you want to deploy. This is ignored when vm_os_id or vm_os_simple are provided."
  type        = string
  default     = "latest"
}

variable "tags" {
  type        = map(string)
  description = "A map of the tags to use on the resources that are deployed with this module."

  default = {
    source = "terraform"
  }
}

variable "storage_account_osdisk_name" {
  type    = string
  default = ""
}

variable "storage_account_datadisk_names" {
  type    = list(string)
  default = []
}

variable "delete_os_disk_on_termination" {
  type        = bool
  description = "Delete os disk when machine is terminated."
  default     = true
}

variable "delete_data_disks_on_termination" {
  type        = bool
  description = "Delete data disk when machine is terminated."
  default     = true
}

variable "os_disk_size_gb" {
  description = "Storage os disk size size."
  type        = number
  default     = null
}
variable "data_disk_size_gb_default" {
  description = "(optional) Default Size of each data disk in GB, if data_disk_sizes_gb is not specified."
  type        = number
  default     = 500
}
variable "data_disk_sizes_gb" {
  description = "(optional) Size of each data disk in GB"
  type        = list(number)
  default     = []
}
variable "data_disk_caching_default" {
  type        = string
  default     = "None"
  description = "(Optional) Specifies the caching requirements for the Data Disk. Possible values include None, ReadOnly and ReadWrite"
}
variable "data_disk_cachings" {
  type        = list(string)
  default     = []
  description = "(Optional) Specifies the caching requirements for the Data Disk. Possible values include None, ReadOnly and ReadWrite"
}

variable "boot_diagnostics" {
  type        = bool
  description = "(Optional) Enable or Disable boot diagnostics."
  default     = false
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

variable "enable_ssh_key" {
  type        = bool
  description = "(Optional) Enable ssh key authentication in Linux virtual Machine."
  default     = false
}

variable "nb_data_disk" {
  description = "(Optional) Number of the data disks attached to each virtual machine."
  type        = number
  default     = 0
}

variable "source_address_prefixes" {
  description = "(Optional) List of source address prefixes allowed to access var.remote_port."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "license_type" {
  description = "Specifies the BYOL Type for this Virtual Machine. This is only applicable to Windows Virtual Machines. Possible values are Windows_Client and Windows_Server"
  type        = string
  default     = null
}

variable "identity_type" {
  description = "The Managed Service Identity Type of this Virtual Machine."
  type        = string
  default     = ""
}

variable "identity_ids" {
  description = "Specifies a list of user managed identity ids to be assigned to the VM."
  type        = list(string)
  default     = []
}
variable "timezone" {
  type    = string
  default = ""
}

variable "use_availability_set" {
  type = bool
  default = false
}

variable "availability_set_platform_fault_domain_count" {
  type = number
  default = 2
}

variable "availability_set_platform_update_domain_count" {
  type = number
  default = 2
}
