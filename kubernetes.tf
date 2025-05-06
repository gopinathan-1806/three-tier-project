provider "kubernetes" {
  host                   = data.ibm_container_cluster_config.cluster_config.host
  client_certificate     = data.ibm_container_cluster_config.cluster_config.admin_certificate
  client_key             = data.ibm_container_cluster_config.cluster_config.admin_key
  cluster_ca_certificate = data.ibm_container_cluster_config.cluster_config.ca_certificate
}

# Get cluster configuration
data "ibm_container_cluster_config" "cluster_config" {
  cluster_name_id   = ibm_container_vpc_cluster.cluster.id
  resource_group_id = ibm_resource_group.resource_group.id
  admin             = true
}

# Create Kubernetes deployment
resource "kubernetes_deployment" "app_deployment" {
  metadata {
    name = var.app_name
    labels = {
      app = var.app_name
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = var.app_name
      }
    }

    template {
      metadata {
        labels = {
          app = var.app_name
        }
      }

      spec {
        container {
          image = "${var.region}.icr.io/${var.cr_namespace}/${var.app_name}:latest"
          name  = var.app_name
          
          port {
            container_port = var.app_port
          }
          
          env {
            name  = "PORT"
            value = var.app_port
          }
          
          env {
            name  = "SECRET_WORD"
            value = "TerraformIBMCloud2025"  # This would be obtained from the index page
          }
          
          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "0.2"
              memory = "256Mi"
            }
          }
          
          liveness_probe {
            http_get {
              path = "/"
              port = var.app_port
            }
            initial_delay_seconds = 10
            timeout_seconds       = 5
            period_seconds        = 10
          }
        }
        
        image_pull_secrets {
          name = kubernetes_secret.image_pull_secret.metadata[0].name
        }
      }
    }
  }
  
  depends_on = [
    kubernetes_secret.image_pull_secret
  ]
}

# Create image pull secret for IBM Container Registry
resource "kubernetes_secret" "image_pull_secret" {
  metadata {
    name = "ibm-cr-pull-secret"
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "${var.region}.icr.io" = {
          username = "iamapikey"
          password = var.ibmcloud_api_key
          auth     = base64encode("iamapikey:${var.ibmcloud_api_key}")
        }
      }
    })
  }
}

# Create Kubernetes service (load balancer)
resource "kubernetes_service" "app_service" {
  metadata {
    name = "${var.app_name}-service"
    annotations = {
      "service.kubernetes.io/ibm-load-balancer-cloud-provider-ip-type" = "public"
      "service.kubernetes.io/ibm-load-balancer-cloud-provider-zone"    = "${var.region}-1"
    }
  }

  spec {
    selector = {
      app = var.app_name
    }
    
    port {
      name        = "http"
      port        = 80
      target_port = var.app_port
    }
    
    port {
      name        = "https"
      port        = 443
      target_port = var.app_port
    }
    
    type = "LoadBalancer"
  }
  
  depends_on = [
    kubernetes_deployment.app_deployment
  ]
}

# Create TLS certificate (self-signed for demo)
resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "cert" {
  private_key_pem = tls_private_key.private_key.private_key_pem
  
  subject {
    common_name  = var.domain_name
    organization = "Example Organization"
  }
  
  validity_period_hours = 8760 # 1 year
  
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

# Create Kubernetes TLS secret
resource "kubernetes_secret" "tls_secret" {
  metadata {
    name = "tls-secret"
  }
  
  data = {
    "tls.crt" = tls_self_signed_cert.cert.cert_pem
    "tls.key" = tls_private_key.private_key.private_key_pem
  }
  
  type = "kubernetes.io/tls"
}

# Create Ingress for TLS termination
resource "kubernetes_ingress_v1" "app_ingress" {
  metadata {
    name = "${var.app_name}-ingress"
    annotations = {
      "kubernetes.io/ingress.class"                 = "public-iks-k8s-nginx"
      "nginx.ingress.kubernetes.io/ssl-redirect"    = "true"
    }
  }
  
  spec {
    tls {
      hosts       = [var.domain_name]
      secret_name = kubernetes_secret.tls_secret.metadata[0].name
    }
    
    rule {
      host = var.domain_name
      
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          
          backend {
            service {
              name = kubernetes_service.app_service.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}
