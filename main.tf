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

module "aks" {
  source                     = "./aks"
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
  database_vm_size         = var.database_vm_size
  database_node_count      = var.database_node_count
  database_az              = var.database_az
  database_os_disk_size_gb = var.database_os_disk_size_gb
  #
  backend_vm_size          = var.backend_vm_size
  backend_node_count       = var.backend_node_count
  backend_az               = var.backend_az
  backend_os_disk_size_gb  = var.backend_os_disk_size_gb
  #
  tag_used_by                = var.tag_used_by
  tag_purpose                = var.tag_purpose
}

module "kubernetes" {
  source                     = "./kubernetes"
  k8s_server_host            = module.aks.api_server_endpoint
  k8s_client_certificate     = module.aks.client_certificate
  k8s_client_key             = module.aks.client_key
  k8s_cluster_ca_certificate = module.aks.cluster_ca_certificate
  prefix_name                = var.prefix_name
  cluster_name               = var.prefix_name
  key_name                   = module.keyvault.disk_encryption_set_id
}
