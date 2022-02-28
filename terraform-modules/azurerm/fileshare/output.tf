output "fileshare_storage_account_id" {
  value = azurerm_storage_account.fileshare.id
}
output "fileshare_storage_account_name" {
  value = azurerm_storage_account.fileshare.name
}
output "fileshare_storage_account_primary_file_host" {
  value = azurerm_storage_account.fileshare.primary_file_host
}
output "fileshare_storage_account_primary_file_endpoint" {
  value = azurerm_storage_account.fileshare.primary_file_endpoint
}
output "fileshare_storage_account_primary_access_key" {
  value     = azurerm_storage_account.fileshare.primary_access_key
  sensitive = true
}
output "fileshare_storage_share_ids" {
  value = [
    for share in azurerm_storage_share.fileshare : share.id
  ]
}
output "fileshare_storage_share_names" {
  value = [for share in azurerm_storage_share.fileshare : share.name]
}
output "fileshare_storage_private_endpoint_id" {
  value = var.private_endpoint_name != "" ? azurerm_private_endpoint.fileshare[0].id : null
}
output "fileshare_storage_private_endpoint_name" {
  value = var.private_endpoint_name != "" ? azurerm_private_endpoint.fileshare[0].name : null
}
output "fileshare_storage_private_endpoint_service_connection_private_ip_addresses" {
  value = var.private_endpoint_name != "" ? azurerm_private_endpoint.fileshare[0].private_service_connection.*.private_ip_address : null
}
output "fileshare_storage_private_endpoint_service_connection_names" {
  value = var.private_endpoint_name != "" ? azurerm_private_endpoint.fileshare[0].private_service_connection.*.name : null
}
