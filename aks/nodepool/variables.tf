variable "aks_cluster_id" {
  description = "The Kubernetes Managed Cluster ID"
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

# Nodepool variables
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

variable "subnet_id" {
  description = "the subnet id for the cluster"
  type        = string
}
