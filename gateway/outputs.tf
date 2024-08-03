output "gateway_id" {
    description = "ID of the application gateway"
    value       = azurerm_application_gateway.gateway.id
}

output "gateway_name" {
    description = "Name of the application gateway"
    value       = azurerm_application_gateway.gateway.name
}

output "gateway_frontend_ip" {
    description = "Public IP address of the application gateway."
    value       = azurerm_public_ip.ip_gateway.ip_address
}