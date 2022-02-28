variable "location" {
  type        = string
  default     = "Germany West Central"
  description = "The Azure Region in which the resources in this example should exist"
}

variable "resource_group_name" {
  type        = string
  description = "The Azure Resource Group"
  default     = ""
}

variable "tags" {
  description = "The tags to associate with your network and subnets."
  type        = map(string)

  default = {
    role = "vpn"
  }
}

variable "virtual_network_name" {
  type        = string
  description = "The name of the virtual network"
  default     = ""
}

# Azure VPN Gateway Variables
variable "subnet_name" {
  type    = string
  default = "GatewaySubnet"
}

variable "subnet_address_prefixes" {
  type    = list(string)
  default = []
}

variable "local_network_gateway_name" {
  type    = string
  default = ""
}

variable "local_network_gateway_gateway_address" {
  type    = string
  default = ""
}

variable "local_network_gateway_address_space" {
  type    = list(string)
  default = []
}

variable "virtual_network_gateway_pip_name" {
  type    = string
  default = ""
}
variable "virtual_network_gateway_pip_allocation_method" {
  type    = string
  default = "Dynamic"
}

variable "virtual_network_gateway_name" {
  type    = string
  default = ""
}

variable "virtual_network_gateway_type" {
  type    = string
  default = "Vpn"
}

variable "virtual_network_gateway_vpn_type" {
  type    = string
  default = "RouteBased"
}
variable "virtual_network_gateway_active_active" {
  type    = bool
  default = false
}
variable "virtual_network_gateway_enable_bgp" {
  type    = bool
  default = false
}
variable "virtual_network_gateway_sku" {
  type    = string
  default = "basic"
}
variable "virtual_network_gateway_private_ip_address_allocation" {
  type    = string
  default = "Dynamic"
}


variable "virtual_network_gateway_connection_name" {
  type    = string
  default = ""
}

variable "virtual_network_gateway_connection_type" {
  type    = string
  default = "IPsec"
}

variable "virtual_network_gateway_connection_shared_key" {
  type      = string
  default   = ""
  sensitive = true
}
