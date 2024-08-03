variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}
variable "client_id" {
  description = "value"
  type        = string
}
variable "client_secret" {
  description = "value"
  type        = string
}
variable "tenant_id" {
  description = "value"
  type        = string
}

variable "service_principal_name" {
  description = "Name of the Azure Service Principal Identity"
  type        = string
}

variable "location_suffix" {
  description = "The Azure location where resources will be created"
  type        = string
}

variable "prefix_name" {
  description = "The name of the Kubernetes cluster"
  type        = string
}

variable "dns_prefix" {
  description = "The DNS prefix for the AKS cluster"
  type        = string
}

variable "os_sku" {
  description = "Specifies the OS SKU used by the agent pool."
  type        = string
  default     = "Ubuntu"
}

# Nodepools variables
# database
variable "database_vm_size" {
  description = "The SKU which should be used for the Virtual Machines used in this Node Pool"
  type        = string
}

variable "database_node_count" {
  description = "Number of nodes"
  type        = number
  default     = 1
}

variable "database_os_disk_size_gb" {
  description = "The Agent Operating System disk size in GB"
  type        = number
  default     = 30
}
variable "database_az" {
  description = "Specifies a list of Availability Zones in which this Kubernetes"
  type        = list(string)
}

# backend
variable "backend_vm_size" {
  description = "The SKU which should be used for the Virtual Machines used in this Node Pool"
  type        = string
}

variable "backend_node_count" {
  description = "Number of nodes"
  type        = number
  default     = 1
}

variable "backend_os_disk_size_gb" {
  description = "The Agent Operating System disk size in GB"
  type        = number
  default     = 30
}
variable "backend_az" {
  description = "Specifies a list of Availability Zones in which this Kubernetes"
  type        = list(string)
}

variable "tag_used_by" {
  description = "This tag identifies the user of this environment"
  type        = string
}

variable "tag_purpose" {
  description = "This tag identifies the purpose of this environment"
  type        = string
}

variable "module_depends_on" {
  default     = [""]
  type        = list(any)
  description = "List of modules that must run before this one"
}

variable "kubernetes_version" {
  description = "Version of the Kubernetes API server"
  type        = string
}

variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "symfony-container-image" {
  description = "Container image for deploying Symfony"
  type        = string
  default     = "bitnami/symfony:6.4.3"
}

variable "database-container-image" {
  description = "Container image for deploying database server"
  type        = string
  default     = ""
}

variable "db-username" {
    description = "Base64 encoded database username"
    type        = string
    default     = "c3ltZm9ueXVzZXI="
}

variable "db-password" {
    description = "Base64 encoded database password"
    type        = string
    default     = "aGVyZVdlZ29BZ2Fpbg=="
}

variable "db-root-password" {
    description = "Base64 encoded database password"
    type        = string
    default     = "SWFtVGhlTWFzdGVy"
}