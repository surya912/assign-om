# Azure AKS Configuration

resource "azurerm_kubernetes_cluster" "main" {
  count               = var.cloud_provider == "azure" ? 1 : 0
  name                = var.cluster_name
  location            = var.region
  resource_group_name = var.resource_group_name
  dns_prefix          = var.cluster_name
  kubernetes_version  = "1.28"

  default_node_pool {
    name                = "default"
    node_count          = var.node_count
    vm_size             = var.node_instance_type
    type                = "VirtualMachineScaleSets"
    enable_auto_scaling = false
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
  }

  tags = var.tags
}

variable "resource_group_name" {
  description = "Azure Resource Group name"
  type        = string
  default     = ""
}

