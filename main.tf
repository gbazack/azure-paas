terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.93.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
    }
    helm     = {
      source = "hashicorp/helm"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
}

data "azurerm_resource_group" "aks" {
  name     = var.resource_group_name
}

data "azurerm_client_config" "aks" {
  # No config
}


# Modules
module "keyvault" {
  source              = "./keyvault"
  tenant_id           = var.tenant_id
  object_id           = data.azurerm_client_config.aks.object_id
  resource_group_name = data.azurerm_resource_group.aks.name
  location            = var.location_suffix
  prefix_name         = var.prefix_name
  tag_used_by         = var.tag_used_by
  tag_purpose         = var.tag_purpose
}

module "network" {
  source              = "./network"
  resource_group_name = data.azurerm_resource_group.aks.name
  location            = var.location_suffix
  prefix_name         = var.prefix_name
  tag_used_by         = var.tag_used_by
  tag_purpose         = var.tag_purpose
}

module "gateway" {
  source              = "./gateway"
  resource_group_name = data.azurerm_resource_group.aks.name
  location            = var.location_suffix
  prefix_name         = var.prefix_name
  network_name        = module.network.network_name
  aks_subnet_id       = module.network.aks_subnet_id
  tag_used_by         = var.tag_used_by
  tag_purpose         = var.tag_purpose
}

module "aks-cluster" {
  source                     = "./aks/cluster"
  resource_group_name        = data.azurerm_resource_group.aks.name
  client_id                  = var.client_id
  client_secret              = var.client_secret
  location                   = var.location_suffix
  prefix_name                = var.prefix_name
  dns_prefix                 = var.dns_prefix
  kubernetes_version         = var.kubernetes_version
  subnet_id                  = module.network.aks_subnet_id
  disk_encryption_set_id     = module.keyvault.vm_disk_encryption_set_id
  key_vault_key_id           = module.keyvault.key_vault_key_id
  gateway_id                 = module.gateway.gateway_id
  #
  tag_used_by                = var.tag_used_by
  tag_purpose                = var.tag_purpose
}

module "nodepool" {
  source                   = "./aks/nodepool"
  aks_cluster_id           = module.aks-cluster.aks_cluster_id
  prefix_name              = var.prefix_name
  subnet_id                = module.network.aks_subnet_id
  nodepool_name            = "backend"
  nodepool_vm_size         = var.nodepool_vm_size
  nodepool_node_count      = var.nodepool_node_count
  nodepool_az              = var.nodepool_az
  nodepool_os_disk_size_gb = var.nodepool_os_disk_size_gb
  #
  tag_used_by              = var.tag_used_by
  tag_purpose              = var.tag_purpose
  #
  depends_on               = [ module.aks-cluster ]
}