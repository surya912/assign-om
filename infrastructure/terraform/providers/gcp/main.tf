terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  backend "gcs" {
    # Configure backend in terraform.tfvars or via environment variables
    bucket = ""
    prefix = "idea-board/terraform.tfstate"
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

# Kubernetes Cluster
module "kubernetes" {
  source = "../../modules/kubernetes"
  
  cloud_provider     = "gcp"
  cluster_name       = "${var.project_name}-cluster"
  region             = var.gcp_region
  node_count         = var.node_count
  node_instance_type = var.node_instance_type
  project_id         = var.gcp_project_id
  network_name       = var.network_name
  subnetwork_name    = var.subnetwork_name
  tags               = var.tags
}

# PostgreSQL Database
module "postgresql" {
  source = "../../modules/postgresql"
  
  cloud_provider = "gcp"
  db_name        = var.db_name
  db_username    = var.db_username
  db_password    = var.db_password
  instance_class = var.db_instance_class
  region         = var.gcp_region
  project_id     = var.gcp_project_id
  network_id     = var.network_id
  tags           = var.tags
}

# Outputs
output "cluster_endpoint" {
  value = module.kubernetes.cluster_endpoint
}

output "cluster_name" {
  value = module.kubernetes.cluster_name
}

output "db_endpoint" {
  value     = module.postgresql.db_endpoint
  sensitive = true
}

output "db_connection_string" {
  value     = module.postgresql.connection_string
  sensitive = true
}

