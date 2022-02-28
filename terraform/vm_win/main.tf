data "azurerm_resource_group" "vm" {
  name = "rg-${var.environment_prefix}-${var.azure_resource_group_postfix}"
}

data "azurerm_virtual_network" "vm" {
  name                = "vnet-${var.environment_prefix}"
  resource_group_name = data.azurerm_resource_group.vm.name
}

data "azurerm_subnet" "subnet" {
  name                 = var.azure_virtual_network_subnet_names[0]
  virtual_network_name = data.azurerm_virtual_network.vm.name
  resource_group_name  = data.azurerm_resource_group.vm.name
}

module "window_vms" {
  source                              = "../../terraform-modules/azurerm/windows_virtual_machine"
  admin_username                      = var.azure_vm_admin_username
  admin_password                      = var.azure_vm_admin_password
  name                                = "vm-${var.environment_prefix}-win"
  hostname                            = "win"
  instance_count                      = 1
  size                                = "Standard_D2ds_v5"
  license_type                        = "Windows_Server"
  resource_group_name                 = data.azurerm_resource_group.vm.name
  virtual_network_resource_group_name = data.azurerm_resource_group.vm.name
  virtual_network_name                = data.azurerm_virtual_network.vm.name
  virtual_network_subnet_name         = data.azurerm_subnet.subnet.name
  os_disk_storage_account_type        = "Standard_LRS"
  os_disk_caching                     = "ReadOnly"
  os_disk_ephemeral                   = true
  os_disk_size_gb                     = 48
  source_image_reference_publisher    = "MicrosoftWindowsServer"
  source_image_reference_offer        = "WindowsServer"
  source_image_reference_sku          = "2022-Datacenter-smalldisk"
  # data_disk_size_gb                   = 10
  # data_disk_storage_account_type = "Standard_LRS"
  # data_disk_create_option = "Empty"
  # data_disk_caching = "ReadWrite"
  # source_image_reference_version = "latest"
  # enable_accelerated_networking = false
  # enable_ip_forwarding = false
  # private_ip_address_allocation = "Static"
  # private_ip_address_start      = 14
  # public_ip                     = true
  # public_ip_dns                 = "azplyg-dc"
  # public_ip_allocation_method = "Dynamic"
  # nsg_allowed_ports = ["tcp_22", "tcp_3389"]
  # nsg_source_address_prefixes = ["0.0.0.0/0"]

  # Optional variables
  # We don't use domainjoin in the module otherwise firstLogonCommands get not
  # executed. But we need them for SSH Access
  # join_domain_name            = var.ad_domain_name
  # join_domain_username        = var.azure_vm_admin_username
  # join_domain_password        = var.azure_vm_admin_password
  # join_domain_oupath          = ""
  tags                              = merge(
    {
      "environment" = var.environment_prefix
    },
    var.azure_tags
    )
  timezone = "W. Europe Standard Time"
}

### The Ansible inventory file
resource "local_file" "AnsibleInventory" {
  content = templatefile("../_files/ansible_inventory.tmpl",
    {
      hostnames          = module.window_vms.vm_hostnames,
      ansible_hosts      = module.window_vms.windows_vm_private_ip_addresses,
      ansible_group      = substr(basename(path.cwd), -4, -1) # dbfs
      is_windows_image   = true
      ansible_host_vars  = ""
      ansible_hostgroups = []
    }
  )
  filename = "${replace(dirname(path.cwd), "terraform", "ansible")}/inventory/${var.generated_for_ansible_file_prefix}${basename(path.cwd)}"

  depends_on = [module.window_vms]
}

output "vm_ids" {
  value = module.window_vms.windows_vm_ids
}
output "vm_private_ip_addresses" {
  value = module.window_vms.windows_vm_private_ip_addresses
}
output "vm_virtual_machine_ids" {
  value = module.window_vms.windows_vm_virtual_machine_ids
}
output "vm_virtual_machine_public_ips" {
  value = module.window_vms.windows_vm_virtual_machine_public_ips
}
output "vm_virtual_machine_fqdns" {
  value = module.window_vms.windows_vm_virtual_machine_fqdns
}
output "vm_virtual_machine_hostnames" {
  value = module.window_vms.vm_hostnames
}
