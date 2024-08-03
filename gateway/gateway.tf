resource "azurerm_subnet" "gateway-frontend" {
    name                 = "${var.prefix_name}-gateway-frontend"
    resource_group_name  = var.resource_group_name
    virtual_network_name = var.network_name
    address_prefixes     = ["10.20.0.0/16"]
}

resource "azurerm_subnet" "gateway-backend" {
    name                 = "${var.prefix_name}-gateway-backend"
    resource_group_name  = var.resource_group_name
    virtual_network_name = var.network_name
    address_prefixes     = ["10.30.0.0/16"]
}

resource "azurerm_public_ip" "ip_gateway" {
    name                 = "${var.prefix_name}-gateway-ip"
    resource_group_name  = var.resource_group_name
    location             = var.location
    allocation_method    = "Static"
    sku                  = "Standard"
    ddos_protection_mode = "Enabled"

    tags                = {
        "Env"     = "${var.prefix_name}-cluster"
        "Used_by" = var.tag_used_by
        "Purpose" = var.tag_purpose
    }
}

resource "azurerm_application_gateway" "gateway"{
    name                = "${var.prefix_name}-gateway"
    resource_group_name = var.resource_group_name
    location            = var.location

    sku {
        name     = "WAF_v2"
        tier     = "WAF_v2"
    }
    autoscale_configuration {
        min_capacity = 4
        max_capacity = 125
    }
    gateway_ip_configuration {
        name       = "${var.prefix_name}-gateway-ip-config"
        subnet_id  = azurerm_subnet.gateway-frontend.id
    }
    frontend_port {
        name = "${var.prefix_name}-http-port"
        port = 80
    }
    frontend_ip_configuration {
        name                 = "${var.prefix_name}-front-ip-config"
        public_ip_address_id = azurerm_public_ip.ip_gateway.id
    }
    backend_address_pool {
        name = "${var.prefix_name}-address-pool"

    }
    backend_http_settings {
        name                  = "${var.prefix_name}-http-settings"
        cookie_based_affinity = "Disabled"
        port                  = 80
        protocol              = "Http"
        request_timeout       = 72000
    }
    http_listener {
        name                           = "${var.prefix_name}-http-listener"
        frontend_ip_configuration_name = "${var.prefix_name}-front-ip-config"
        frontend_port_name             = "${var.prefix_name}-http-port"
        protocol                       = "Http"
    }
    request_routing_rule {
        name                       = "${var.prefix_name}-http-rule"
        rule_type                  = "Basic"
        http_listener_name         = "${var.prefix_name}-http-listener"
        backend_address_pool_name  = "${var.prefix_name}-address-pool"
        backend_http_settings_name = "${var.prefix_name}-http-settings"
        priority                   = 1
        rewrite_rule_set_name      = "${var.prefix_name}-rule-set"
    }
    # WAF Configuration -----------------------------------------------------
    waf_configuration {
        enabled              = true
        firewall_mode        = "Detection"
        rule_set_version     = 3.2
        file_upload_limit_mb = 750
    }
    # Secure HTTP Headers Configuration -------------------------------------
    rewrite_rule_set {
        name = "${var.prefix_name}-rule-set"
        rewrite_rule {
            name = "${var.prefix_name}-rule-1"
            rule_sequence = 1
            # response_header_configuration {
            #     header_name  = "Clear-Site-Data"
            #     header_value = "\"cache\", \"cookies\", \"storage\""
            # }
            # response_header_configuration {
            #     header_name  = "Cache-Control"
            #     header_value = "no-store, max-age=0"
            # }
            response_header_configuration {
                header_name  = "Content-Security-Policy"
                header_value = "default-src 'self'; form-action 'self'; object-src 'none'; frame-ancestors 'none'; upgrade-insecure-requests; block-all-mixed-content"
            }
        }
        rewrite_rule {
            name = "${var.prefix_name}-rule-2"
            rule_sequence = 2
            response_header_configuration {
                header_name  = "Cross-Origin-Embedder-Policy"
                header_value = "require-corp"
            }
            response_header_configuration {
                header_name  = "Cross-Origin-Opener-Policy"
                header_value = "same-origin"
            }
            response_header_configuration {
                header_name  = "Cross-Origin-Resource-Policy"
                header_value = "same-origin"
            }
        }
        rewrite_rule {
            name = "${var.prefix_name}-rule-3"
            rule_sequence = 3
            response_header_configuration {
                header_name  = "Permissions-Policy"
                header_value = "camera=(),geolocation=(),microphone=()"
            }
            response_header_configuration {
                header_name  = "Referrer-Policy"
                header_value = "no-referrer"
            }
            response_header_configuration {
                header_name  = "Strict-Transport-Security"
                header_value = "max-age=31536000; includeSubDomains"
            }
        }
        rewrite_rule {
            name = "${var.prefix_name}-rule-4"
            rule_sequence = 4
            response_header_configuration {
                header_name  = "X-Content-Type-Options"
                header_value = "nosniff"
            }
            response_header_configuration {
                header_name  = "X-Frame-Options"
                header_value = "deny"
            }
            response_header_configuration {
                header_name  = "X-Permitted-Cross-Domain-Policies"
                header_value = "none"
            }
            response_header_configuration {
                header_name  = "X-XSS-Protection"
                header_value = "0"
            }
        }
        rewrite_rule {
            name = "${var.prefix_name}-rule-5"
            rule_sequence = 5
            response_header_configuration {
                header_name  = "Access-Control-Allow-Credentials"
                header_value = "true"
            }
            response_header_configuration {
                header_name  = "Access-Control-Allow-Origin"
                header_value = "https://pentest.opensee.net"
            }
            response_header_configuration {
                header_name  = "Access-Control-Headers"
                header_value = "Accept, Accept-Encoding, Accept-Language, asOf, Authorization, Bearer, buildAt, commit, Connection, Content-Type, dataModelSpecs, ENGINE_VERSION, Host, Origin, PREFLIGHT-AUTHORIZATION, PRIORITY, Referer, request-id, Request-Time, session-id, spanId, Specs, tableName, traceId, traceparent, tracestate, User-Agent, Vary, version, X-AS-SessionID, X-Version"
            }
            response_header_configuration {
                header_name  = "Access-Control-Allow-Methods"
                header_value = "POST, GET, PUT, PATCH, OPTIONS, DELETE"
            }
            response_header_configuration {
                header_name  = "Access-Control-Expose-Headers"
                header_value = "Date, Content-Type, Content-Length, request-id"
            }
            response_header_configuration {
                header_name  = "Access-Control-Max-Age"
                header_value = "86400"
            }
        }
    }

    tags                  = {
        "Env"     = "${var.prefix_name}-cluster"
        "Used_by" = var.tag_used_by
        "Purpose" = var.tag_purpose
    }
}

resource "azurerm_network_interface" "nic" {
  count               = 2
  name                = "${var.prefix_name}-nic-gateway-${count.index+1}"
  resource_group_name = var.resource_group_name
  location            = var.location

  ip_configuration {
    name                          = "nic-ipconfig-${count.index+1}"
    subnet_id                     = azurerm_subnet.gateway-backend.id
    private_ip_address_allocation = "Dynamic"
  }
  
  tags                = {
    "Env"     = "${var.prefix_name}-cluster"
    "Used_by" = var.tag_used_by
    "Purpose" = var.tag_purpose
    }
}

resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "nic-assoc" {
  count                   = 2
  network_interface_id    = azurerm_network_interface.nic[count.index].id
  ip_configuration_name   = "nic-ipconfig-${count.index+1}"
  backend_address_pool_id = one(azurerm_application_gateway.gateway.backend_address_pool).id
}
