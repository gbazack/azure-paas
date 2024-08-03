output "kube_config" {
  description = "Raw Kubernetes config to be used by kubectl and other compatible tools."
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}
output "aks_cluster_id" {
  description = "The Kubernetes Managed Cluster ID."
  value       = azurerm_kubernetes_cluster.aks.id
}
output "api_server_endpoint" {
  description = "The Kubernetes cluster server host."
  value       = azurerm_kubernetes_cluster.aks.kube_config[0].host
}

output "client_key" {
  description = "Private key used by clients to authenticate to the Kubernetes cluster."
  value       = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_key)
  sensitive   = true
}

output "client_certificate" {
  description = "Public certificate used by clients to authenticate to the Kubernetes cluster."
  value       = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate)
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "Public CA certificate used as the root of trust for the Kubernetes cluster."
  value       = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].cluster_ca_certificate)
  sensitive   = true
}