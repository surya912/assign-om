terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    # Configure backend in terraform.tfvars or via environment variables
    bucket = ""
    key    = "idea-board/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
}

# VPC and Networking
module "networking" {
  source = "../../modules/networking"
  
  cloud_provider = "aws"
  region         = var.aws_region
  vpc_cidr       = var.vpc_cidr
  project_name   = var.project_name
}

# Kubernetes Cluster
module "kubernetes" {
  source = "../../modules/kubernetes"
  
  cloud_provider     = "aws"
  cluster_name       = "${var.project_name}-cluster"
  region             = var.aws_region
  node_count         = var.node_count
  node_instance_type = var.node_instance_type
  subnet_ids         = module.networking.private_subnet_ids
  tags               = var.tags
}

# PostgreSQL Database
module "postgresql" {
  source = "../../modules/postgresql"
  
  cloud_provider = "aws"
  db_name        = var.db_name
  db_username    = var.db_username
  db_password    = var.db_password
  instance_class = var.db_instance_class
  region         = var.aws_region
  subnet_ids     = module.networking.private_subnet_ids
  vpc_id         = module.networking.vpc_id
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

