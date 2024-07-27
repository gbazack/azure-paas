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

# nodepool variables
variable "nodepool_name" {
  description = "The name of the Node Pool"
  type        = string
}

variable "nodepool_vm_size" {
  description = "The SKU which should be used for the Virtual Machines used in this Node Pool"
  type        = string
}
variable "nodepool_node_count" {
  description = "Number of nodes"
  type        = number
  default     = 1
}

variable "nodepool_os_disk_size_gb" {
  description = "The Agent Operating System disk size in GB"
  type        = number
  default     = 30
}
variable "nodepool_az" {
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

variable "env_dns_name" {
    description = "DNS name of the environment"
    type        = string
}

variable "cloud_dns_sa" {
    description = "Path to GCP service account"
    type        = string
}

variable "gandi_api_key" {
    description = "API key for access to Gandi"
    type        = string
}

variable "letsencrypt_solver" {
    description = "Type of challenge mechanis used by Cert-manager"
    type        = string
    default     = "http"
}