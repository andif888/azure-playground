data "azurerm_resource_group" "vpn" {
  name = "rg-${var.environment_prefix}-${var.azure_resource_group_postfix}"
}

data "azurerm_virtual_network" "vpn" {
  name                = "vnet-${var.environment_prefix}"
  resource_group_name = data.azurerm_resource_group.vpn.name
}

data "azurerm_route_table" "vpn" {
  name                = "rtb-${var.environment_prefix}"
  resource_group_name = data.azurerm_resource_group.vpn.name
}

module "vpn" {
  source                                = "../../terraform-modules/azurerm/network_gateway"
  local_network_gateway_address_space   = ["192.168.120.0/24", "172.35.0.0/16", "172.19.254.0/24"]
  local_network_gateway_gateway_address = "87.138.137.98"
  local_network_gateway_name            = "lngw-${var.environment_prefix}-vpn"
  location                              = data.azurerm_resource_group.vpn.location
  resource_group_name                   = data.azurerm_resource_group.vpn.name
  subnet_address_prefixes               = ["10.10.254.0/29"]
  # subnet_name                                             = "GatewaySubnet"
  virtual_network_name             = data.azurerm_virtual_network.vpn.name
  virtual_network_gateway_pip_name = "pip-${var.environment_prefix}-vpn"
  # virtual_network_gateway_pip_allocation_method           = "Dynamic"
  virtual_network_gateway_name = "vngw-${var.environment_prefix}-vpn"
  # virtual_network_gateway_type                            = "Vpn"
  # virtual_network_gateway_vpn_type                        = "RouteBased"
  # virtual_network_gateway_active_active                   = false
  # virtual_network_gateway_enable_bgp                      = false
  # virtual_network_gateway_sku                             = "basic"
  # virtual_network_gateway_private_ip_address_allocation   = "Dynamic"
  virtual_network_gateway_connection_name = "vngw-${var.environment_prefix}-con"
  # virtual_network_gateway_connection_type                 = "IPsec"

  # Use export TF_VAR_virtual_network_gateway_connection_shared_key="YourSecretKey" in your .env file
  # virtual_network_gateway_connection_shared_key = "YourSecretKey"

  tags = merge(
    {
      "environment" = "${var.environment_prefix}",
      "role"        = "vpn"
    },
    var.azure_tags
  )
}

resource "azurerm_subnet_route_table_association" "vpn" {
  subnet_id      = module.vpn.subnet_id
  route_table_id = data.azurerm_route_table.vpn.id

  depends_on = [module.vpn]
}

output "vpn_local_network_gateway_id" {
  value = module.vpn.local_network_gateway_id
}
output "vpn_virtual_network_gateway_public_ip" {
  value = module.vpn.virtual_network_gateway_public_ip
}
output "vpn_subnet_id" {
  value = module.vpn.subnet_id
}
output "vpn_virtual_network_gateway_id" {
  value = module.vpn.virtual_network_gateway_id
}
output "vpn_virtual_network_gateway_connection_id" {
  value = module.vpn.virtual_network_gateway_connection_id
}
