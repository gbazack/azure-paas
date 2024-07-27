resource "azurerm_virtual_network" "vnet" {
    name                = "${var.prefix_name}-vnet"
    resource_group_name = var.resource_group_name
    location            = var.location
    address_space       = ["10.0.0.0/8"]

    tags                = {
        "Env"     = "${var.prefix_name}-cluster"
        "Used_by" = var.tag_used_by
        "Purpose" = var.tag_purpose
    }
}

resource "azurerm_subnet" "aks" {
  name                 = "${var.prefix_name}-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.10.0.0/16"]
}