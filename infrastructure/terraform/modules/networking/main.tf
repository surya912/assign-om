# Cloud-agnostic networking module

variable "cloud_provider" {
  description = "Cloud provider: aws, gcp, or azure"
  type        = string
}

variable "region" {
  description = "Cloud provider region"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

# AWS-specific outputs
output "vpc_id" {
  value = var.cloud_provider == "aws" ? aws_vpc.main[0].id : ""
}

output "private_subnet_ids" {
  value = var.cloud_provider == "aws" ? aws_subnet.private[*].id : []
}

output "public_subnet_ids" {
  value = var.cloud_provider == "aws" ? aws_subnet.public[*].id : []
}

