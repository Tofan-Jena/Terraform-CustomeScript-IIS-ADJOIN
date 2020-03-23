# Configure the Azure Provider
provider "azurerm" {
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  version = "=2.0.0"
  features {}
}

provider "azurerm" {
  alias = "frontend"
  features {}
  subscription_id = "${var.subscription_id_f}"
  client_id       = "${var.client_id_f}"
  client_secret   = var.secret_id_f
  tenant_id       = "${var.tenant_id_f}"
  # Frontend - Subscription Details - NEWRDS
}


provider "azurerm" {
alias = "backend"
features {}
subscription_id = "${var.subscription_id_b}"
  client_id       = "${var.client_id_b}"
  client_secret   = var.secret_id_b
  tenant_id       = "${var.tenant_id_b}"
# Backend - Subscription Details -RDSLAB
  
}

resource "azurerm_resource_group" "backend" {
  provider = "azurerm.backend"
  name     = "${var.RGName-Prefix}-${count.index}-backend"
  location = "South India"
  tags     = {
    Owner = "Tofan"
    App   = "Lab"

  }
  count = "${var.counts}"
  
}

resource "azurerm_resource_group" "frontend" {
  provider = "azurerm.frontend"
  name     = "${var.RGName-Prefix}-${count.index}-frontend"
  location = "west india"
  count    = "${var.counts}"
}
