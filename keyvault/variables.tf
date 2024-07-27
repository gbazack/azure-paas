variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string 
}

variable "location" {
  description = "The Azure location where resources will be created"
  type        = string
}

variable "tenant_id" {
  description = "value"
  type        = string
}

variable "object_id" {
  description = "value"
  type        = string
}

variable "prefix_name" {
  description = "The name of the Kubernetes cluster"
  type        = string 
}

variable "tag_used_by" {
  description = "This tag identifies the user of this environment"
  type        = string
}

variable "tag_purpose" {
  description = "This tag identifies the purpose of this environment"
  type        = string
}