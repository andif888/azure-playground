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

data "azurerm_storage_account" "vm" {
  name                = var.azure_storage_account_name
  resource_group_name = data.azurerm_resource_group.vm.name
}

module "azure_vms" {
  source                      = "../../terraform-modules/azurerm/virtual_machine_unmanaged_disk" # uses unmanaged disks
  admin_password              = var.azure_vm_admin_password
  admin_username              = var.azure_vm_admin_username
  name                        = "vm-${var.environment_prefix}-rdg"
  hostname                    = "rdg"
  instance_count              = 1
  size                        = "Standard_B2s"
  is_windows_image            = true
  license_type                = "Windows_Server"
  resource_group_name         = data.azurerm_resource_group.vm.name
  virtual_network_name        = data.azurerm_virtual_network.vm.name # Network: Centrally managed
  virtual_network_subnet_id   = data.azurerm_subnet.subnet.id        # Network: Centrally managed
  virtual_network_subnet_name = data.azurerm_subnet.subnet.name      # Network: Centrally managed
  # proximity_placement_group_name    = ""
  # use_availability_set = false
  # availability_set_platform_fault_domain_count = 2
  # availability_set_platform_update_domain_count = 2

  storage_account_osdisk_name = data.azurerm_storage_account.vm.name
  # delete_os_disk_on_termination     = true
  # os_disk_size_gb                   = null

  vm_os_publisher = "MicrosoftWindowsServer"
  vm_os_offer     = "WindowsServer"
  vm_os_sku       = "2022-Datacenter-smalldisk"
  vm_os_version   = "latest"

  # storage_account_datadisk_names    = []
  # delete_data_disks_on_termination  = true
  # boot_diagnostics                  = false
  # nb_data_disk                      = 0
  # data_disk_size_gb_default         = 500
  # data_disk_sizes_gb                = []
  # data_disk_caching_default         = "None"
  # data_disk_cachings                = []

  # enable_accelerated_networking     = false
  # enable_ip_forwarding              = false
  private_ip_address_start      = 11
  private_ip_address_allocation = "Static"
  # public_ip                         = false
  # public_ip_dns                     = ""
  # allocation_method                 = "Dynamic"
  # nsg_allowed_ports                 = []

  public_key_openssh = file("${var.ssh_private_key_internal_terraform}.pub")
  enable_ssh_key     = true
  # disable_password_authentication   = false
  # custom_data                       = "${path.module}/setup/firstrun.bat"
  # windows_unattend_firstlogon_xml = "FirstLogonCommands.xml"

  timezone = var.azure_vm_windows_timezone
  tags = merge(
    {
      "environment" = var.environment_prefix
    },
    var.azure_tags
  )
}

### The Ansible inventory file
resource "local_file" "AnsibleInventory" {
  content = templatefile("../_files/ansible_inventory.tmpl",
    {
      hostnames          = module.azure_vms.vm_hostnames,
      ansible_hosts      = module.azure_vms.network_interface_private_ip,
      ansible_group      = substr(basename(path.cwd), -3, -1) # rdg
      is_windows_image   = true
      ansible_host_vars  = ""
      ansible_hostgroups = ["windows_members", "windows_rdg", "windows_mgmt_tools"]
    }
  )
  filename = "${replace(dirname(path.cwd), "terraform", "ansible")}/inventory/${var.generated_for_ansible_file_prefix}${basename(path.cwd)}"

  depends_on = [module.azure_vms]
}

output "azure_vms_vm_ids" {
  value = module.azure_vms.vm_ids
}
output "azure_vms_network_security_group_id" {
  value = module.azure_vms.network_security_group_id
}
output "azure_vms_network_security_group_name" {
  value = module.azure_vms.network_security_group_name
}
output "azure_vms_network_interface_ids" {
  value = module.azure_vms.network_interface_ids
}
output "azure_vms_network_interface_private_ip" {
  value = module.azure_vms.network_interface_private_ip
}
output "azure_vms_public_ip_id" {
  value = module.azure_vms.public_ip_id
}

output "azure_vms_public_ip_dns_name" {
  value = module.azure_vms.public_ip_dns_name
}
output "azure_vms_private_ip_address" {
  value = module.azure_vms.network_interface_private_ip
}
output "azure_vms_availability_set_id" {
  value = module.azure_vms.availability_set_id
}
# output "azure_vms_vm_zones" {
#   value = module.azure_vms.vm_zones
# }
output "azure_vms_vm_identity" {
  value = module.azure_vms.vm_identity
}
output "azure_vms_vm_hostnames" {
  value = module.azure_vms.vm_hostnames
}
output "azure_vms_vm_hostnames_ansible_p" {
  value = module.azure_vms.vm_hostnames_ansible_p
}
