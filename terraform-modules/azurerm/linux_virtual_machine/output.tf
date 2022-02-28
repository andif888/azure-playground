output "linux_vm_ids" {
  value = azurerm_linux_virtual_machine.vm.*.id
}
output "linux_vm_private_ip_addresses" {
  value = azurerm_linux_virtual_machine.vm.*.private_ip_address
}
output "linux_vm_virtual_machine_ids" {
  value = azurerm_linux_virtual_machine.vm.*.virtual_machine_id
}
output "linux_vm_virtual_machine_public_ips" {
  value = var.public_ip ? azurerm_linux_virtual_machine.vm.*.public_ip_address : null
}
output "linux_vm_virtual_machine_fqdns" {
  value = var.public_ip ? azurerm_public_ip.vm.*.fqdn : null
}
output "vm_hostnames" {
  value = data.template_file.ips.*.vars.hostname
}
