provider "kubernetes" {
    host                   = var.k8s_server_host
    client_certificate     = var.k8s_client_certificate
    client_key             = var.k8s_client_key
    cluster_ca_certificate = var.k8s_cluster_ca_certificate
}

locals {
  env = var.cluster_name
}

// Kubernetes Encrypted GCE StorageClass
resource "kubernetes_storage_class" "csi" {
  metadata {
    name = "${local.env}-sc"
  }
  storage_provisioner = "disk.csi.azure.com"
  reclaim_policy      = "Retain"
  volume_binding_mode = "WaitForFirstConsumer"
  parameters = {
    kind = "managed"
    diskEncryptionSetID = var.key_name
  }
}

// symfony Workload Configurations
// Kubernetes Namespaces
resource "kubernetes_namespace" "symfony-database" {
  metadata {
    name   = "database"
    labels = {
      "symfony.io/name"                            = "mariadb"
      "symfony.io/tier"                            = "database"
      "symfony.io/app"                             = "symfony"
      "pod-security.kubernetes.io/enforce"         = "baseline"
      "pod-security.kubernetes.io/enforce-version" = "v1.29"
      "pod-security.kubernetes.io/audit"           = "restricted"
      "pod-security.kubernetes.io/audit-version"   = "v1.29"
      "pod-security.kubernetes.io/warn"            = "restricted"
      "pod-security.kubernetes.io/warn-version"    = "v1.29"
    }
  }
}

resource "kubernetes_namespace" "symfony-backend" {
  metadata {
    name   = "backend"
    labels = {
      "symfony.io/name"                            = "symfony"
      "symfony.io/tier"                            = "backend"
      "symfony.io/app"                             = "symfony"
      "pod-security.kubernetes.io/enforce"         = "baseline"
      "pod-security.kubernetes.io/enforce-version" = "v1.29"
      "pod-security.kubernetes.io/audit"           = "restricted"
      "pod-security.kubernetes.io/audit-version"   = "v1.29"
      "pod-security.kubernetes.io/warn"            = "restricted"
      "pod-security.kubernetes.io/warn-version"    = "v1.29"
    }
  }
}

// Kubernetes ServiceAccounts
resource "kubernetes_service_account" "backend" {
  metadata {
    name                = "backend-sa"
    namespace           = "backend"
    labels    = {
      "symfony.io/name" = "backend-sa"
      "symfony.io/tier" = "backend"
      "symfony.io/app"  = "symfony"
    }
  }
  depends_on = [ kubernetes_namespace.symfony-backend ] 
}

resource "kubernetes_service_account" "database" {
  metadata {
    name                = "database-sa"
    namespace           = "database"
    labels    = {
      "symfony.io/name" = "database-sa"
      "symfony.io/tier" = "database"
      "symfony.io/app"  = "symfony"
    }
  }
  depends_on = [ kubernetes_namespace.symfony-database ] 
}

// Kubernetes Secrets
resource "kubernetes_secret" "symfony-database-secret" {
  metadata {
    name                = "databa-secret"
    namespace           = "backend"
    labels    = {
      "symfony.io/name" = "databa-secret"
      "symfony.io/tier" = "backend"
      "symfony.io/app"  = "symfony"
    }
  }
  
  data = {
    "password"          = var.db-password
    "root-password"     = var.db-root-password
    "username"          = var.db-username
  }
  depends_on = [ kubernetes_namespace.symfony-backend ]
}

resource "kubernetes_secret" "database-secret" {
  metadata {
    name                = "databa-secret"
    namespace           = "database"
    labels    = {
      "symfony.io/name" = "databa-secret"
      "symfony.io/tier" = "database"
      "symfony.io/app"  = "symfony"
    }
  }
  
  data = {
    "password"          = var.db-password
    "root-password"     = var.db-root-password
    "username"          = var.db-username
  }
  depends_on = [ kubernetes_namespace.symfony-database ]
}

// Kubernetes Statefulset
resource "kubernetes_stateful_set" "database" {
  metadata {
    name      = "mariadb"
    namespace = "database"
    labels = {
      "symfony.io/name" = "mariadb"
      "symfony.io/tier" = "database"
      "symfony.io/app"  = "symfony"
    }

  }
  spec {
    replicas               = 1
    selector {
      match_labels = {
        "symfony.io/name" = "mariadb"
        "symfony.io/tier" = "database"
      }
    }
    service_name = "mariadb"

    template {
      metadata {
        labels = {
          "symfony.io/name" = "mariadb"
          "symfony.io/tier" = "database"
          "symfony.io/app"  = "symfony"
        }
      }

      spec {
        service_account_name = "database-sa"
        affinity {
          node_affinity {
            required_during_scheduling_ignored_during_execution {
              node_selector_term {
                match_expressions {
                  key      = "agentpool"
                  operator = "In"
                  values   = ["database"]
                }
              }
            }
          }
          pod_anti_affinity {
            required_during_scheduling_ignored_during_execution {
              topology_key = "topology.kubernetes.io/zone"
              label_selector {
                match_expressions {
                  key      = "symfony.io/tier"
                  operator = "In"
                  values   = ["backend"]
                }
              }
            }
          }
        }
        container {
          name              = "mariadb"
          image             = var.database-container-image
          image_pull_policy = "Always"
          port {
            container_port = 3306
          }
          resources {
            limits = {
              cpu    = "1000m"
              memory = "1000Mi"
            }
            requests = {
              cpu    = "200m"
              memory = "200Mi"
            }
          }
          env {
            name  = "MARIADB_DATABASE"
            value = "symfonydb"
          }
          env {
            name  = "MARIADB_USER"
            value_from {
              secret_key_ref {
                name = "databa-secret"
                key  = "username"
              }
            }
          }
          env {
            name  = "MARIADB_PASSWORD"
            value_from {
              secret_key_ref {
                name = "databa-secret"
                key  = "password"
              }
            }
          }
          env {
            name  = "MARIADB_ROOT_PASSWORD"
            value_from {
              secret_key_ref {
                name = "databa-secret"
                key  = "root-password"
              }
            }
          }
          security_context {
            allow_privilege_escalation = "false"
          }          
          volume_mount {
            name       = "mariadb-conf"
            mount_path = "/etc/mysql/conf.d"
            read_only  = false
          }
          volume_mount {
            name       = "mariadb-data"
            mount_path = "/var/lib/mysql"
            read_only  = false
          }
        
        }
      }
    }
    volume_claim_template {
      metadata {
        name = "mariadb-conf"
      }
      spec {
        access_modes       = ["ReadWriteOnce"]
        storage_class_name = "${local.env}-sc"
        resources {
          requests = {
            storage = "5Gi"
          }
        }
      }
    }
    volume_claim_template {
      metadata {
        name = "mariadb-data"
      }
      spec {
        access_modes       = ["ReadWriteOnce"]
        storage_class_name = "${local.env}-sc"
        resources {
          requests = {
            storage = "10Gi"
          }
        }
      }
    }
  }
  depends_on = [ 
    kubernetes_secret.database-secret,
    kubernetes_service_account.database,
    kubernetes_storage_class.csi
   ]
}

// Kubernetes Deployment
resource "kubernetes_deployment" "symfony" {
  metadata {
    name                    = "symfony"
    namespace               = "backend"
    labels    = {
      "symfony.io/name"     = "symfony"
      "symfony.io/tier"     = "backend"
      "symfony.io/app"      = "symfony"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
      "symfony.io/name"     = "symfony"
      "symfony.io/tier"     = "backend"
      "symfony.io/app"      = "symfony"
      }
    }
    template {
      metadata {
        labels = {
          "symfony.io/name"     = "symfony"
          "symfony.io/tier"     = "backend"
          "symfony.io/app"      = "symfony"
        }
      }

      spec {
        service_account_name = "backend-sa"
        affinity {
          node_affinity {
            required_during_scheduling_ignored_during_execution {
              node_selector_term {
                match_expressions {
                  key      = "agentpool"
                  operator = "In"
                  values   = ["backend"]
                }
              }
            }
          }
          pod_anti_affinity {
            required_during_scheduling_ignored_during_execution {
              topology_key = "topology.kubernetes.io/zone"
              label_selector {
                match_expressions {
                  key      = "symfony.io/tier"
                  operator = "In"
                  values   = ["database"]
                }
              }
            }
          }
        }
        container {
          image             = var.symfony-container-image
          image_pull_policy = "Always"
          name              = "symfony"

          resources {
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
            requests = {
              cpu    = "100m"
              memory = "100Mi"
            }
          }
          env {
            name  = "SYMFONY_PROJECT_SKELETON"
            value = "symfony/skeleton"
          }
          env {
            name  = "SYMFONY_DATABASE_HOST"
            value = "mariadb.database.svc.cluster.local"
          }
          env {
            name  = "SYMFONY_DATABASE_PORT_NUMBER"
            value = "3306"
          }
          env {
            name  = "SYMFONY_DATABASE_NAME"
            value = "symfonydb"
          }
          env {
            name  = "SYMFONY_DATABASE_USER"
            value_from {
              secret_key_ref {
                name = "databa-secret"
                key  = "username"
              }
            }
          }
          env {
            name  = "SYMFONY_DATABASE_PASSWORD"
            value_from {
              secret_key_ref {
                name = "databa-secret"
                key  = "password"
              }
            }
          }
          port {
            container_port = 8000
          }
          security_context {
            allow_privilege_escalation = "false"
          }
        }
      }
    }
  }
  depends_on = [ 
    kubernetes_service_account.backend,
    kubernetes_secret.symfony-database-secret,
    kubernetes_stateful_set.database
  ]
}


// Kubernetes Services
resource "kubernetes_service" "symfony-database" {
  metadata {
   name                    = "mariadb"
   namespace               = "database" 
    labels = {
      "symfony.io/name"    = "mariadb"
      "symfony.io/tier"    = "database"
      "symfony.io/app"     = "symfony"
    }
  }
  spec{
    selector = {
      "symfony.io/name"    = "mariadb"
      "symfony.io/tier"    = "database"
      "symfony.io/app"     = "symfony"
    }
    port {
      port        = 3306
      target_port = 3306
    }
    type = "ClusterIP"
  }
  depends_on = [ kubernetes_stateful_set.database ]
}

resource "kubernetes_service" "symfony-backend" {
  metadata {
   name                    = "symfony-svc"
   namespace               = "backend" 
    labels = {
      "symfony.io/name"    = "symfony-svc"
      "symfony.io/tier"    = "ingress"
      "symfony.io/app"     = "symfony"
    }
  }
  spec{
    selector = {
      "symfony.io/name"    = "symfony"
      "symfony.io/tier"    = "backend"
      "symfony.io/app"     = "symfony"
    }
    port {
      port        = 8000
      target_port = 8000
    }
    type = "NodePort"
  }
  depends_on = [ kubernetes_deployment.symfony ]
}

// Kubernetes Ingress
resource "kubernetes_ingress_v1" "symfony-ingress" {
    metadata {
        name      = "symfony-ingress"
        namespace = "backend"
        labels = {
          "symfony.io/name"     = "symfony-ingress"
          "symfony.io/tier"     = "backend"
          "symfony.io/app"      = "symfony"
        }
        annotations = {
          "appgw.ingress.kubernetes.io/rewrite-rule-set" = "${var.prefix_name}-rule-set"
          "appgw.ingress.kubernetes.io/request-timeout"  = 72000
          "kubernetes.io/ingress.allow-http"             = "true"
        }
    }
    spec {
        ingress_class_name = "azure-application-gateway"
        rule {
            http {
                path {
                    path = "/*"
                    path_type = "ImplementationSpecific"
                    backend {
                        service {
                            name = "symfony-svc"
                            port {
                                number = 8000
                            }
                        }
                    }
                }
            }
        }
    }
    depends_on = [kubernetes_service.symfony-backend]
}