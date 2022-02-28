resource "azurerm_local_network_gateway" "vpn" {
  name                = var.local_network_gateway_name
  location            = var.location
  resource_group_name = var.resource_group_name
  gateway_address     = var.local_network_gateway_gateway_address
  address_space       = var.local_network_gateway_address_space
  tags                = var.tags
}

resource "azurerm_public_ip" "vpn" {
  name                = var.virtual_network_gateway_pip_name
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = var.virtual_network_gateway_pip_allocation_method

  tags = var.tags
}


resource "azurerm_subnet" "vpn" {
  name                 = var.subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = var.subnet_address_prefixes
}

resource "azurerm_virtual_network_gateway" "vpn" {
  name                = var.virtual_network_gateway_name
  location            = var.location
  resource_group_name = var.resource_group_name

  type     = var.virtual_network_gateway_type
  vpn_type = var.virtual_network_gateway_vpn_type

  active_active = var.virtual_network_gateway_active_active
  enable_bgp    = var.virtual_network_gateway_enable_bgp
  sku           = var.virtual_network_gateway_sku

  ip_configuration {
    public_ip_address_id          = azurerm_public_ip.vpn.id
    private_ip_address_allocation = var.virtual_network_gateway_private_ip_address_allocation
    subnet_id                     = azurerm_subnet.vpn.id
  }
  tags = var.tags

  depends_on = [azurerm_public_ip.vpn]
}

resource "azurerm_virtual_network_gateway_connection" "vpn" {
  name                = var.virtual_network_gateway_connection_name
  location            = var.location
  resource_group_name = var.resource_group_name

  type                       = var.virtual_network_gateway_connection_type
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vpn.id
  local_network_gateway_id   = azurerm_local_network_gateway.vpn.id
  shared_key                 = var.virtual_network_gateway_connection_shared_key
  tags                       = var.tags
}
