#resource "azurerm_resource_group" "rg" {
#  name     = var.resource_group_name
#  location = var.location
#}

#resource "azurerm_virtual_network" "vnet" {
#  name                = "Test-Vnet"
#  address_space       = ["172.25.0.0/16"]
#  location            = var.location
#  resource_group_name = var.resource_group_name
#  dns_servers         = ["172.25.0.13"]
#}

#resource "azurerm_subnet" "subnet" {
#  name                 = "${var.vm_name}-Subnet"
#  resource_group_name  = var.resource_group_name
#  virtual_network_name = var.vnet
#  address_prefixes     = ["10.0.25.0/24"]
#}

resource "azurerm_network_interface" "nic" {
  name                = "${var.vm_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.existing_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_storage_account" "my_storage_account" {
  name                     = "diag${random_id.random_id.hex}"
  location                 = var.location
  resource_group_name      = var.resource_group_name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_virtual_machine" "vm" {
  name                  = var.vm_name
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.nic.id]
  vm_size               = "Standard_D8s_v4"
  delete_os_disk_on_termination = true #This will ensure that the OS disk is deleted when the VM is destroyed.

  storage_os_disk {
    name              = "${var.vm_name}_OsDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
    disk_size_gb      = 127
  }

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }

  os_profile {
    computer_name  = var.vm_name
    admin_username = var.admin_username
    admin_password = var.admin_password
    custom_data    = filebase64("custom_script.ps1")
  }

  os_profile_windows_config {
    provision_vm_agent        = true
    timezone                  = "AUS Eastern Standard Time"
  }

  boot_diagnostics {
    enabled             = true
    storage_uri         = azurerm_storage_account.my_storage_account.primary_blob_endpoint
  }
}
resource "random_id" "random_id" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = var.resource_group_name
  }
  byte_length = 8
}

resource "azurerm_managed_disk" "data_disk" {
  name                 = "${var.vm_name}_DataDisk1"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = 100
}

resource "azurerm_virtual_machine_data_disk_attachment" "data_disk_attachment" {
  managed_disk_id    = azurerm_managed_disk.data_disk.id
  virtual_machine_id = azurerm_virtual_machine.vm.id
  lun                = 0
  caching            = "ReadWrite"
}

module "domain-join" {
  source = "kumarvna/domain-join/azurerm"
  version = "1.1.0"

  virtual_machine_id       = azurerm_virtual_machine.vm.id
  active_directory_domain  = var.domain_name
  active_directory_username = var.domain_user
  active_directory_password = var.domain_password
  ou_path                  = var.ou_path
  tags = {
    ProjectName = "migration-project"
    Env         = "dev"
    Owner       = "user@example.com"
    BusinessUnit = "CORP"
    ServiceClass = "Gold"
  }
}