terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.93.0"
    }
  }
}

provider "azurerm" {
  features {}
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
}

data "azurerm_resource_group" "tfstate" {
  name     = var.resource_group_name
}

resource "azurerm_storage_account" "tfstate" {
  name                     = var.storage_account_name
  resource_group_name      = data.azurerm_resource_group.tfstate.name
  location                 = var.location_suffix
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = {
    "Env"     = "${var.prefix_name}-cluster"
    "Used_by" = var.tag_used_by
    "Purpose" = var.tag_purpose
  }

  depends_on               = [data.azurerm_resource_group.tfstate]
}

resource "azurerm_storage_container" "tfstate" {
  name                  = var.container_name
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"

  depends_on            = [data.azurerm_resource_group.tfstate]
}