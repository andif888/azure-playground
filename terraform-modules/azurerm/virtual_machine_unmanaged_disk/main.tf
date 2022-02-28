module "os" {
  source       = "./os"
  vm_os_simple = var.vm_os_simple
}

data "azurerm_resource_group" "vm" {
  name = var.resource_group_name
}

data "azurerm_subnet" "subnet" {
  name                 = var.virtual_network_subnet_name
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.resource_group_name
}

data "azurerm_proximity_placement_group" "ppg" {
  count               = length(var.proximity_placement_group_name) > 0 ? 1 : 0
  name                = var.proximity_placement_group_name
  resource_group_name = var.resource_group_name
}

data "template_file" "ips" {
  count    = var.instance_count
  template = "$${ip}"

  vars = {
    ip             = cidrhost(data.azurerm_subnet.subnet.address_prefixes[0], count.index + var.private_ip_address_start)
    hostname       = "${var.hostname}${count.index}"
    ansible_host_p = "${var.hostname}${count.index}-p"
  }
}

data "template_file" "linux-vm-cloud-init" {
  template = file(coalesce(var.custom_data, "${path.module}/setup/cloudinit.tpl"))
}

data "template_file" "windows-vm-cloud-init" {
  template = file(coalesce(var.custom_data, "${path.module}/setup/firstrun.bat"))
  vars = {
    ssh_public_key = length(var.public_key_openssh) > 0 ? var.public_key_openssh : ""
  }
}

data "azurerm_storage_account" "vm-sa-osdisk" {
  name                = var.storage_account_osdisk_name
  resource_group_name = var.resource_group_name
}
data "azurerm_storage_account" "vm-sa-datadisk" {
  count               = length(var.storage_account_datadisk_names)
  name                = element(var.storage_account_datadisk_names, count.index)
  resource_group_name = var.resource_group_name
}

resource "azurerm_availability_set" "vm" {
  count                        = var.use_availability_set ? 1 : 0
  name                         = "avset-${var.name}"
  resource_group_name          = data.azurerm_resource_group.vm.name
  location                     = coalesce(var.location, data.azurerm_resource_group.vm.location)
  proximity_placement_group_id = length(var.proximity_placement_group_name) > 0 ? data.azurerm_proximity_placement_group.ppg[0].id : null
  platform_fault_domain_count  = var.availability_set_platform_fault_domain_count
  platform_update_domain_count = var.availability_set_platform_update_domain_count
  managed                      = false # Must be false because of unmanaged disks
  tags                         = merge({ "resourcename" = format("%s", lower(replace("avset-${var.name}", "/[[:^alnum:]]/", ""))) }, var.tags, )
}

resource "azurerm_public_ip" "vm" {
  count               = var.public_ip ? var.instance_count : 0
  name                = "pip-${var.name}${count.index}"
  resource_group_name = data.azurerm_resource_group.vm.name
  location            = coalesce(var.location, data.azurerm_resource_group.vm.location)
  allocation_method   = var.allocation_method
  domain_name_label   = var.public_ip_dns_no_index ? "${var.public_ip_dns}" : "${var.public_ip_dns}${count.index}"
  tags                = merge({ "resourcename" = format("%s", lower(replace("pip-${var.name}${count.index}", "/[[:^alnum:]]/", ""))) }, var.tags, )
}

resource "azurerm_network_interface" "vm" {
  count                         = var.instance_count
  name                          = "nic-${var.name}${count.index}"
  resource_group_name           = data.azurerm_resource_group.vm.name
  location                      = coalesce(var.location, data.azurerm_resource_group.vm.location)
  enable_accelerated_networking = var.enable_accelerated_networking
  enable_ip_forwarding          = var.enable_ip_forwarding

  ip_configuration {
    name                          = "nicc-${var.name}${count.index}"
    subnet_id                     = var.virtual_network_subnet_id
    private_ip_address_allocation = var.private_ip_address_allocation
    private_ip_address            = var.private_ip_address_allocation == "Static" ? element(data.template_file.ips.*.rendered, count.index) : ""
    public_ip_address_id          = length(azurerm_public_ip.vm.*.id) > 0 ? element(concat(azurerm_public_ip.vm.*.id, tolist([""])), count.index) : ""
  }

  tags = merge({ "resourcename" = format("%s", lower(replace("nic-${var.name}${count.index}", "/[[:^alnum:]]/", ""))) }, var.tags, )

  depends_on = [azurerm_public_ip.vm]
}

resource "azurerm_network_security_group" "vm" {
  count               = var.public_ip ? 1 : 0
  name                = "nsg-${var.name}"
  resource_group_name = data.azurerm_resource_group.vm.name
  location            = coalesce(var.location, data.azurerm_resource_group.vm.location)

  tags = merge({ "resourcename" = format("%s", lower(replace("nsg-${var.name}", "/[[:^alnum:]]/", ""))) }, var.tags, )

  depends_on = [azurerm_network_interface.vm]
}


resource "azurerm_network_security_rule" "allow_ports" {
  count                       = var.public_ip && length(var.nsg_allowed_ports) > 0 ? length(var.nsg_allowed_ports) : 0
  name                        = "allow_remote_${element(var.nsg_allowed_ports, count.index)}_in_all"
  resource_group_name         = data.azurerm_resource_group.vm.name
  description                 = "Allow remote protocol in from all locations"
  priority                    = 101 + count.index
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = element(split("_", element(var.nsg_allowed_ports, count.index)), 0)
  source_port_range           = "*"
  destination_port_range      = element(split("_", element(var.nsg_allowed_ports, count.index)), 1)
  source_address_prefixes     = var.source_address_prefixes
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.vm[0].name

  depends_on = [azurerm_network_security_group.vm]
}

resource "azurerm_network_interface_security_group_association" "test" {
  count                     = var.public_ip ? var.instance_count : 0
  network_interface_id      = azurerm_network_interface.vm[count.index].id
  network_security_group_id = azurerm_network_security_group.vm[0].id

  depends_on = [azurerm_network_security_group.vm, azurerm_network_interface.vm]
}


resource "azurerm_virtual_machine" "vm-linux" {
  count                            = !contains(tolist([var.vm_os_simple, var.vm_os_offer]), "WindowsServer") && !var.is_windows_image ? var.instance_count : 0
  name                             = "${var.name}${count.index}"
  resource_group_name              = data.azurerm_resource_group.vm.name
  location                         = coalesce(var.location, data.azurerm_resource_group.vm.location)
  availability_set_id              = var.use_availability_set ? azurerm_availability_set.vm[0].id : null
  vm_size                          = var.size
  network_interface_ids            = [element(azurerm_network_interface.vm.*.id, count.index)]
  delete_os_disk_on_termination    = var.delete_os_disk_on_termination
  delete_data_disks_on_termination = var.delete_data_disks_on_termination
  proximity_placement_group_id     = length(var.proximity_placement_group_name) > 0 ? data.azurerm_proximity_placement_group.ppg[0].id : null

  dynamic "identity" {
    for_each = length(var.identity_ids) == 0 && var.identity_type == "SystemAssigned" ? [var.identity_type] : []
    content {
      type = var.identity_type
    }
  }

  dynamic "identity" {
    for_each = length(var.identity_ids) > 0 || var.identity_type == "UserAssigned" ? [var.identity_type] : []
    content {
      type         = var.identity_type
      identity_ids = length(var.identity_ids) > 0 ? var.identity_ids : []
    }
  }

  storage_image_reference {
    id        = var.vm_os_id
    publisher = var.vm_os_id == "" ? coalesce(var.vm_os_publisher, module.os.calculated_value_os_publisher) : ""
    offer     = var.vm_os_id == "" ? coalesce(var.vm_os_offer, module.os.calculated_value_os_offer) : ""
    sku       = var.vm_os_id == "" ? coalesce(var.vm_os_sku, module.os.calculated_value_os_sku) : ""
    version   = var.vm_os_id == "" ? var.vm_os_version : ""
  }

  storage_os_disk {
    name          = "osdisk-${var.name}${count.index}"
    create_option = "FromImage"
    caching       = "ReadWrite"
    #managed_disk_type = var.storage_account_type
    vhd_uri      = "${data.azurerm_storage_account.vm-sa-osdisk.primary_blob_endpoint}vhd/${var.name}${count.index}-osdisk.vhd"
    disk_size_gb = var.os_disk_size_gb
  }

  dynamic "storage_data_disk" {
    for_each = range(var.nb_data_disk)
    content {
      name          = "${var.name}-datadisk-${count.index}-${storage_data_disk.value}"
      create_option = "Empty"
      lun           = storage_data_disk.value
      disk_size_gb  = length(var.data_disk_sizes_gb) > 0 ? element(var.data_disk_sizes_gb, storage_data_disk.value) : var.data_disk_size_gb_default
      vhd_uri       = length(var.storage_account_datadisk_names) > 0 ? "${data.azurerm_storage_account.vm-sa-datadisk[storage_data_disk.value].primary_blob_endpoint}vhd/${var.name}-${count.index}-datadisk-${storage_data_disk.value}.vhd" : "${data.azurerm_storage_account.vm-sa-osdisk.primary_blob_endpoint}vhd/${var.name}-${count.index}-datadisk-${storage_data_disk.value}.vhd"
      caching       = length(var.data_disk_cachings) > 0 ? element(var.data_disk_cachings, storage_data_disk.value) : var.data_disk_caching_default
    }
  }

  os_profile {
    computer_name  = "${var.hostname}${count.index}"
    admin_username = var.admin_username
    admin_password = var.admin_password
    # custom_data    = var.custom_data
    custom_data = base64encode(data.template_file.linux-vm-cloud-init.rendered)
  }

  os_profile_linux_config {
    disable_password_authentication = var.enable_ssh_key && var.disable_password_authentication

    dynamic "ssh_keys" {
      for_each = var.enable_ssh_key ? [var.public_key_openssh] : []
      content {
        path     = "/home/${var.admin_username}/.ssh/authorized_keys"
        key_data = var.public_key_openssh
      }
    }
  }

  tags = merge({ "resourcename" = format("%s", lower(replace("${var.name}${count.index}", "/[[:^alnum:]]/", ""))) }, var.tags, )

  boot_diagnostics {
    enabled     = var.boot_diagnostics
    storage_uri = var.boot_diagnostics ? data.azurerm_storage_account.vm-sa-osdisk.primary_blob_endpoint : ""
  }

  depends_on = [azurerm_network_interface.vm, azurerm_network_interface_security_group_association.test]
}

resource "azurerm_virtual_machine" "vm-windows" {
  count                            = (var.is_windows_image || contains(tolist([var.vm_os_simple, var.vm_os_offer]), "WindowsServer")) ? var.instance_count : 0
  name                             = "${var.name}${count.index}"
  resource_group_name              = data.azurerm_resource_group.vm.name
  location                         = coalesce(var.location, data.azurerm_resource_group.vm.location)
  availability_set_id              = var.use_availability_set ? azurerm_availability_set.vm[0].id : null
  vm_size                          = var.size
  network_interface_ids            = [element(azurerm_network_interface.vm.*.id, count.index)]
  delete_os_disk_on_termination    = var.delete_os_disk_on_termination
  delete_data_disks_on_termination = var.delete_data_disks_on_termination
  license_type                     = var.license_type
  proximity_placement_group_id     = length(var.proximity_placement_group_name) > 0 ? data.azurerm_proximity_placement_group.ppg[0].id : null

  dynamic "identity" {
    for_each = length(var.identity_ids) == 0 && var.identity_type == "SystemAssigned" ? [var.identity_type] : []
    content {
      type = var.identity_type
    }
  }

  dynamic "identity" {
    for_each = length(var.identity_ids) > 0 || var.identity_type == "UserAssigned" ? [var.identity_type] : []
    content {
      type         = var.identity_type
      identity_ids = length(var.identity_ids) > 0 ? var.identity_ids : []
    }
  }

  storage_image_reference {
    id        = var.vm_os_id
    publisher = var.vm_os_id == "" ? coalesce(var.vm_os_publisher, module.os.calculated_value_os_publisher) : ""
    offer     = var.vm_os_id == "" ? coalesce(var.vm_os_offer, module.os.calculated_value_os_offer) : ""
    sku       = var.vm_os_id == "" ? coalesce(var.vm_os_sku, module.os.calculated_value_os_sku) : ""
    version   = var.vm_os_id == "" ? var.vm_os_version : ""
  }

  storage_os_disk {
    name          = "${var.name}-osdisk${count.index}"
    create_option = "FromImage"
    caching       = "ReadWrite"
    vhd_uri       = "${data.azurerm_storage_account.vm-sa-osdisk.primary_blob_endpoint}vhd/${var.name}${count.index}-osdisk.vhd"
    disk_size_gb  = var.os_disk_size_gb
  }

  dynamic "storage_data_disk" {
    for_each = range(var.nb_data_disk)
    content {
      name          = "${var.name}-datadisk-${count.index}-${storage_data_disk.value}"
      create_option = "Empty"
      lun           = storage_data_disk.value
      disk_size_gb  = length(var.data_disk_sizes_gb) > 0 ? element(var.data_disk_sizes_gb, storage_data_disk.value) : var.data_disk_size_gb_default
      vhd_uri       = length(var.storage_account_datadisk_names) > 0 ? "${data.azurerm_storage_account.vm-sa-datadisk[storage_data_disk.value].primary_blob_endpoint}vhd/${var.name}-${count.index}-datadisk-${storage_data_disk.value}.vhd" : "${data.azurerm_storage_account.vm-sa-osdisk.primary_blob_endpoint}vhd/${var.name}-${count.index}-datadisk-${storage_data_disk.value}.vhd"
      # vhd_uri           = "${data.azurerm_storage_account.vm-sa-datadisk.primary_blob_endpoint}vhd/${var.name}-${count.index}-datadisk-${storage_data_disk.value}.vhd"
      caching = length(var.data_disk_cachings) > 0 ? element(var.data_disk_cachings, storage_data_disk.value) : var.data_disk_caching_default
    }
  }

  os_profile {
    computer_name  = "${var.hostname}${count.index}"
    admin_username = var.admin_username
    admin_password = var.admin_password
    # custom_data    = file(coalesce(var.custom_data, "${path.module}/setup/firstrun.bat"))
    custom_data = base64encode(data.template_file.windows-vm-cloud-init.rendered)

  }

  tags = merge({ "resourcename" = format("%s", lower(replace("${var.name}${count.index}", "/[[:^alnum:]]/", ""))) }, var.tags, )

  os_profile_windows_config {
    provision_vm_agent = true
    timezone           = var.timezone

    # Auto-Login's required to configure WinRM
    additional_unattend_config {
      pass         = "oobeSystem"
      component    = "Microsoft-Windows-Shell-Setup"
      setting_name = "AutoLogon"
      content      = "<AutoLogon><Password><Value>${var.admin_password}</Value></Password><Enabled>true</Enabled><LogonCount>1</LogonCount><Username>${var.admin_username}</Username></AutoLogon>"
    }

    # Unattend config is to enable basic auth in WinRM, required for the provisioner stage.
    additional_unattend_config {
      pass         = "oobeSystem"
      component    = "Microsoft-Windows-Shell-Setup"
      setting_name = "FirstLogonCommands"
      #content      = file("./files/FirstLogonCommands.xml")
      content = file(coalesce(var.windows_unattend_firstlogon_xml, "${path.module}/setup/FirstLogonCommands.xml"))
    }

  }

  boot_diagnostics {
    enabled     = var.boot_diagnostics
    storage_uri = var.boot_diagnostics ? data.azurerm_storage_account.vm-sa-osdisk.primary_blob_endpoint : ""
  }

  depends_on = [azurerm_network_interface.vm, azurerm_network_interface_security_group_association.test]
}
