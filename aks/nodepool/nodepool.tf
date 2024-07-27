# nodepool
resource "azurerm_kubernetes_cluster_node_pool" "nodepool" {
  name                   = var.nodepool_name
  kubernetes_cluster_id  = var.aks_cluster_id
  vm_size                = var.nodepool_vm_size
  vnet_subnet_id         = var.subnet_id
  node_count             = var.nodepool_node_count
  os_disk_size_gb        = var.nodepool_os_disk_size_gb
  os_sku                 = var.os_sku
  zones                  = var.nodepool_az
  enable_host_encryption = true

  tags                   = {
    "Env"     = "${var.prefix_name}-cluster"
    "Used_by" = var.tag_used_by
    "Purpose" = var.tag_purpose
  }
}