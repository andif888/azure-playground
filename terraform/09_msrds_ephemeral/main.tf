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

module "msrdcb_vms" {
  source                              = "../../terraform-modules/azurerm/windows_virtual_machine"
  admin_username                      = var.azure_vm_admin_username
  admin_password                      = var.azure_vm_admin_password
  public_key_openssh                  = file("${var.ssh_private_key_internal_terraform}.pub")
  name                                = "vm-${var.environment_prefix}-erdcb"
  hostname                            = "erdcb"
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
  # public_ip_dns                 = ""
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
  timezone = var.azure_vm_windows_timezone
}

module "msrdsh_vms" {
  source                              = "../../terraform-modules/azurerm/windows_virtual_machine"
  admin_username                      = var.azure_vm_admin_username
  admin_password                      = var.azure_vm_admin_password
  public_key_openssh                  = file("${var.ssh_private_key_internal_terraform}.pub")
  name                                = "vm-${var.environment_prefix}-erdsh"
  hostname                            = "erdsh"
  instance_count                      = 3
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
  # private_ip_address_start      = 20
  # public_ip                     = true
  # public_ip_dns                 = ""
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
  timezone = var.azure_vm_windows_timezone
}

### The Ansible inventory file
resource "local_file" "AnsibleInventory_rdcb" {
  content = templatefile("../_files/ansible_inventory.tmpl",
    {
      hostnames          = module.msrdcb_vms.vm_hostnames,
      ansible_hosts      = module.msrdcb_vms.windows_vm_private_ip_addresses,
      ansible_group      = "rdcb"
      is_windows_image   = true
      ansible_host_vars  = ""
      ansible_hostgroups = ["windows_rdcb", "windows_members"]
    }
  )
  filename = "${replace(dirname(path.cwd), "terraform", "ansible")}/inventory/${var.generated_for_ansible_file_prefix}${basename(path.cwd)}_erdcb"

  depends_on = [module.msrdcb_vms]
}

resource "local_file" "AnsibleInventory_rdsh" {
  content = templatefile("../_files/ansible_inventory.tmpl",
    {
      hostnames          = module.msrdsh_vms.vm_hostnames,
      ansible_hosts      = module.msrdsh_vms.windows_vm_private_ip_addresses,
      ansible_group      = "rdhost"
      is_windows_image   = true
      ansible_host_vars  = ""
      ansible_hostgroups = ["windows_rdsh", "windows_members"]
    }
  )
  filename = "${replace(dirname(path.cwd), "terraform", "ansible")}/inventory/${var.generated_for_ansible_file_prefix}${basename(path.cwd)}_erdsh"

  depends_on = [module.msrdsh_vms]
}

output "msrdcb_vms_ids" {
  value = module.msrdcb_vms.windows_vm_ids
}
output "msrdcb_vms_private_ip_addresses" {
  value = module.msrdcb_vms.windows_vm_private_ip_addresses
}
output "msrdcb_vms_virtual_machine_ids" {
  value = module.msrdcb_vms.windows_vm_virtual_machine_ids
}
output "msrdcb_vms_virtual_machine_public_ips" {
  value = module.msrdcb_vms.windows_vm_virtual_machine_public_ips
}
output "msrdcb_vms_virtual_machine_fqdns" {
  value = module.msrdcb_vms.windows_vm_virtual_machine_fqdns
}
output "msrdcb_vms_virtual_machine_hostnames" {
  value = module.msrdcb_vms.vm_hostnames
}


output "msrdsh_vms_ids" {
  value = module.msrdsh_vms.windows_vm_ids
}
output "msrdsh_vms_private_ip_addresses" {
  value = module.msrdsh_vms.windows_vm_private_ip_addresses
}
output "msrdsh_vms_virtual_machine_ids" {
  value = module.msrdsh_vms.windows_vm_virtual_machine_ids
}
output "msrdsh_vms_virtual_machine_public_ips" {
  value = module.msrdsh_vms.windows_vm_virtual_machine_public_ips
}
output "msrdsh_vms_virtual_machine_fqdns" {
  value = module.msrdsh_vms.windows_vm_virtual_machine_fqdns
}
output "msrdsh_vms_virtual_machine_hostnames" {
  value = module.msrdsh_vms.vm_hostnames
}
