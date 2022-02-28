variable "tags" {
  description = "The tags to associate with your network and subnets."
  type        = map(string)
  default     = {}
}

variable "location" {
  type        = string
  default     = ""
  description = "The Azure Region in which the resources in this example should exist"
}

variable "resource_group_name" {
  type        = string
  description = "The Azure Resource Group"
  default     = ""
}
variable "name" {
  type        = string
  description = "The name of the key_vault"
  default     = ""
}
