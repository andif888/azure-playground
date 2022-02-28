provider "azurerm" {
  # Whilst version is optional, we /strongly recommend/ using it to pin the version of the Provider being used
  # version = "~> 2.19"
  features {}
}

terraform {
  backend "azurerm" {
  }
}
