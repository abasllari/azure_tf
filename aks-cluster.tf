resource "random_pet" "prefix" {}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "default" {
  name     = "${random_pet.prefix.id}-rg"
  location = "West US 2"

  tags = {
    environment = "Demo"
  }
}

resource "azurerm_kubernetes_cluster" "default" {
  name                = "${random_pet.prefix.id}-aks"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  dns_prefix          = "${random_pet.prefix.id}-k8s"

  default_node_pool {
    name            = "default"
    node_count      = 2
    vm_size         = "Standard_D2_v2"
    os_disk_size_gb = 30
  }

  service_principal {
    client_id     = var.appId
    client_secret = var.password
  }

  role_based_access_control {
    enabled = true
  }

  tags = {
    environment = "Demo"
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_namespace" "default" {
  metadata {
    name = "nginx"
  }
}

resource "kubernetes_deployment" "test" {
  metadata {
    name      = "nginx"
  }
  spec {
    replicas = 2
      selector {
          match_labels = {
            app = "MyApp"
          }
        }
    template {
      metadata {
        labels = {
          app = "MyApp"
        }
      }
      spec {

        container {
          image = "nginx"
          name = "nginx-container"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "test" {
  metadata {
    name = "nginx"
  }
  spec {
    type = "NodePort"
    port {
      node_port = 30201
      port = 80
      target_port = "80"
    }
  }
}




