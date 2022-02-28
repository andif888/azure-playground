
output "network_vnet_id" {
  description = "The id of the newly created vNet"
  value       = azurerm_virtual_network.network.id
}
output "network_vnet_name" {
  description = "The Name of the newly created vNet"
  value       = azurerm_virtual_network.network.name
}
output "network_vnet_location" {
  description = "The location of the newly created vNet"
  value       = azurerm_virtual_network.network.location
}
output "network_vnet_address_space" {
  description = "The address space of the newly created vNet"
  value       = azurerm_virtual_network.network.address_space
}
output "network_vnet_subnets" {
  description = "The ids of subnets created inside the newl vNet"
  value       = azurerm_subnet.network.*.id
}
output "network_route_table_id" {
  value = azurerm_route_table.network.id
}
output "network_route_table_name" {
  value = azurerm_route_table.network.name
}
