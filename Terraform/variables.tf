variable "resource_group_name" {
  type        = string
   default     = "AZ-SYD-PROD-01"
#  default     = "SYD-Infrastructure-Test"
  description = "Name of the resource group."
}

variable "vnet" {
  type = string
  default = "Employsure_Production_Supernet"
}

variable "existing_subnet_id" {
  type = string
  default = "/subscriptions/7a39a08c-83c1-4a9b-a148-fde1f031d39d/resourceGroups/AZ-SYD-INF-01/providers/Microsoft.Network/virtualNetworks/Employsure_Production_Supernet/subnets/Production"
  description = "Production subnet inside AZ-SYD-PROD-01 Vnet"
}

variable "location" {
  type        = string
  default     = "australiaeast"
  description = "Location of the resources."
}

variable "vm_name" {
  type        = string
  default     = "HSVMEMPMG4"
  description = "Name of the virtual machine."
}

variable "admin_username" {
  type        = string
  default     = "employsureit"
  description = "Admin username for the virtual machine."
}

variable "admin_password" {
  type        = string
  default      = "Employ@@111"
  description = "Admin password for the virtual machine."
}

variable "domain_name" {
  type        = string
  default      = "Employsure.local"
}

variable "domain_user" {
  type        = string
  default      = "mehdi.rezaei.adm"
}

variable "domain_password" {
  type = string
  default = "1Employ@131@#"
}

variable "ou_path" {
  description = "The Organizational Unit path where the VM should be placed"
  type        = string
  default     = "OU=Servers,DC=employsure,DC=local"
}

