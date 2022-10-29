resource "azurerm_virtual_network" "network" {
  name                = var.virtual_network_name
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = [var.virtual_network_address_space]
  dns_servers         = length(var.virtual_network_dns_servers) > 0 ? var.virtual_network_dns_servers : null

  tags = merge({ "resourcename" = format("%s", lower(replace(var.virtual_network_name, "/[[:^alnum:]]/", ""))) }, var.tags, )
}

resource "azurerm_subnet" "network" {
  count                                          = length(var.virtual_network_subnet_names)
  name                                           = var.virtual_network_subnet_names[count.index]
  resource_group_name                            = var.resource_group_name
  address_prefixes                               = [var.virtual_network_subnet_address_prefixes[count.index]]
  virtual_network_name                           = azurerm_virtual_network.network.name
  private_endpoint_network_policies_enabled      = var.virtual_network_subnet_enforce_private_link_endpoint_network_policies
  service_endpoints                              = var.virtual_network_subnet_service_endpoints

  depends_on = [azurerm_virtual_network.network]
}

resource "azurerm_route_table" "network" {
  name                          = var.route_table_name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  disable_bgp_route_propagation = var.route_table_disable_bgp_route_propagation

  dynamic "route" {
    for_each = var.route_table_routes
    content {
      name                   = route.value.name
      address_prefix         = route.value.address_prefix
      next_hop_type          = route.value.next_hop_type
      next_hop_in_ip_address = route.value.next_hop_in_ip_address == "" ? null : route.value.next_hop_in_ip_address

    }
  }

  tags = merge({ "resourcename" = format("%s", lower(replace(var.route_table_name, "/[[:^alnum:]]/", ""))) }, var.tags, )

}

resource "azurerm_subnet_route_table_association" "network" {
  subnet_id      = azurerm_subnet.network[0].id
  route_table_id = azurerm_route_table.network.id
}
