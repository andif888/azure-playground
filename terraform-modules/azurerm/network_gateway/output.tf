output "local_network_gateway_id" {
  value = azurerm_local_network_gateway.vpn.id
}

output "virtual_network_gateway_public_ip" {
  value = azurerm_public_ip.vpn.ip_address
}

output "subnet_id" {
  value = azurerm_subnet.vpn.id
}

output "virtual_network_gateway_id" {
  value = azurerm_virtual_network_gateway.vpn.id
}

output "virtual_network_gateway_connection_id" {
  value = azurerm_virtual_network_gateway_connection.vpn.id
}
