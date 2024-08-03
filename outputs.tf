output "gateway_frontend_ip" {
    description = "Public IPv4 address of application gateway"
    value       = module.gateway.gateway_frontend_ip
}