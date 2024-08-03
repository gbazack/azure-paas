resource "azurerm_kubernetes_cluster" "aks" {
  name                      = "${var.prefix_name}-cluster"
  location                  = var.location
  resource_group_name       = var.resource_group_name

  dns_prefix                = var.dns_prefix
  private_cluster_enabled   = false
  automatic_channel_upgrade = "stable"
  kubernetes_version        = var.kubernetes_version

  disk_encryption_set_id    = var.disk_encryption_set_id

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS3_v2"

    vnet_subnet_id = var.subnet_id
    tags                  = {
      "Env"     = "${var.prefix_name}-cluster"
      "Used_by" = var.tag_used_by
      "Purpose" = var.tag_purpose
    }
  }

  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }

  ingress_application_gateway {
    gateway_id = var.gateway_id
  }


  tags                  = {
    "Env"     = "${var.prefix_name}-cluster"
    "Used_by" = var.tag_used_by
    "Purpose" = var.tag_purpose
  }

}

# Database nodepool
resource "azurerm_kubernetes_cluster_node_pool" "database" {
  name                   = "database"
  kubernetes_cluster_id  = azurerm_kubernetes_cluster.aks.id
  vm_size                = var.database_vm_size
  vnet_subnet_id         = var.subnet_id
  node_count             = var.database_node_count
  os_disk_size_gb        = var.database_os_disk_size_gb
  os_sku                 = var.os_sku
  zones                  = var.database_az
  enable_host_encryption = true

  tags                   = {
    "Env"     = "${var.prefix_name}-cluster"
    "Used_by" = var.tag_used_by
    "Purpose" = var.tag_purpose
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "backend" {
  name                   = "backend"
  kubernetes_cluster_id  = azurerm_kubernetes_cluster.aks.id
  vm_size                = var.backend_vm_size
  vnet_subnet_id         = var.subnet_id
  node_count             = var.backend_node_count
  os_disk_size_gb        = var.backend_os_disk_size_gb
  os_sku                 = var.os_sku
  zones                  = var.backend_az
  enable_host_encryption = true

  tags                   = {
    "Env"     = "${var.prefix_name}-cluster"
    "Used_by" = var.tag_used_by
    "Purpose" = var.tag_purpose
  }
}
