variable "tags" {
  description = "The tags to associate with your network and subnets."
  type        = map(string)
  default     = {}
}

variable "location" {
  type        = string
  default     = ""
  description = "The Azure Region in which the resources in this example should exist"
}

variable "resource_group_name" {
  type        = string
  description = "The Azure Resource Group"
  default     = ""
}

variable "virtual_network_name" {
  type        = string
  description = "The name of the virtual network"
  default     = ""
}

variable "virtual_network_subnet_names" {
  type        = list(string)
  description = "The name of the virtual network's subnet"
  default     = []
}

variable "virtual_network_subnet_enforce_private_link_endpoint_network_policies" {
  type    = bool
  default = false
}

variable "virtual_network_subnet_service_endpoints" {
  type    = list(string)
  default = []
}

variable "virtual_network_dns_servers" {
  type    = list(string)
  default = []
}

variable "virtual_network_address_space" {
  default     = ""
  description = "The ip range of the virtual network"
}

variable "virtual_network_subnet_address_prefixes" {
  default     = []
  description = "The ip range of the virtual network"
}

variable "route_table_name" {
  type    = string
  default = ""
}

variable "route_table_disable_bgp_route_propagation" {
  type    = bool
  default = false
}

variable "route_table_routes" {
  type = list(object({
    name                   = string,
    address_prefix         = string,
    next_hop_type          = string,
    next_hop_in_ip_address = string
  }))
  default = []
}
