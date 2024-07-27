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

  # key_management_service {
  #   key_vault_key_id         = var.key_vault_key_id
  #   key_vault_network_access = "Public"
  # }

  ingress_application_gateway {
    gateway_id = var.gateway_id
  }


  tags                  = {
    "Env"     = "${var.prefix_name}-cluster"
    "Used_by" = var.tag_used_by
    "Purpose" = var.tag_purpose
  }

}