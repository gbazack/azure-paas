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

variable "location" {
  description = "The Azure location where resources will be created"
  type        = string
}

variable "prefix_name" {
  description = "The name of the Kubernetes cluster"
  type        = string
}

variable "os_sku" {
  description = "Specifies the OS SKU used by the agent pool."
  type        = string
  default     = "Ubuntu"
}

variable "disk_encryption_set_id" {
  description = "value"
  type        = string
}

variable "key_vault_key_id" {
  description = "value"
  type        = string
}

variable "gateway_id" {
  description = "The ID of the Application Gateway to integrate with the ingress controller"
  type        = string
  default     = ""
}

variable "tag_used_by" {
  description = "This tag identifies the user of this environment"
  type        = string
}

variable "tag_purpose" {
  description = "This tag identifies the purpose of this environment"
  type        = string
}

variable "dns_prefix" {
  description = "The DNS prefix for the AKS cluster"
  type        = string
}

variable "subnet_id" {
  description = "the subnet id for the cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Version of the Kubernetes API server"
  type        = string
}