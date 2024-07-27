output "network_name" {
  description = "The virtual NetworkConfiguration ID."
  value       = azurerm_virtual_network.vnet.name
}

output "network_id" {
  description = "The virtual NetworkConfiguration ID."
  value       = azurerm_virtual_network.vnet.id
}

output "aks_subnet_id" {
  description = "The subnet ID"
  value       = azurerm_subnet.aks.id
}

output "aks_subnet_address_prefixes" {
  description = " The address prefixes for the subnet"
  value       = azurerm_subnet.aks.address_prefixes
}