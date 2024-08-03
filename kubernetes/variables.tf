variable "k8s_server_host" {
    description = "Kubernetes Cluster server host url"
    type        = string
}

variable "k8s_client_certificate" {
    description = "Kubernetes Cluster client certificate"
    type        = string
}

variable "k8s_client_key" {
    description = "Kubernetes Cluster client key"
    type        = string
}

variable "k8s_cluster_ca_certificate" {
    description = "Kubernetes Cluster CA certificate"
    type        = string
}

variable "prefix_name" {
    description = "Prefix name"
    type        = string
}

variable "cluster_name" {
  description = "The name of the Kubernetes cluster"
  type        = string
}

variable "key_name" {
  type        = string
  description = "kms mey name of cluster"
}

variable "symfony-container-image" {
  description = "Container image for deploying Symfony"
  type        = string
  default     = "bitnami/symfony:6.4.3"
}

variable "database-container-image" {
  description = "Container image for deploying database server"
  type        = string
  default     = "mariadb:11.4.2-ubi"
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