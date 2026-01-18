# Cloud-agnostic PostgreSQL module
# Supports RDS, Cloud SQL, and Azure Database

variable "db_name" {
  description = "Name of the database"
  type        = string
}

variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "ideaboard"
}

variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}

variable "instance_class" {
  description = "Database instance class/type"
  type        = string
  default     = "db.t3.micro"
}

variable "region" {
  description = "Cloud provider region"
  type        = string
}

variable "cloud_provider" {
  description = "Cloud provider: aws, gcp, or azure"
  type        = string
  validation {
    condition     = contains(["aws", "gcp", "azure"], var.cloud_provider)
    error_message = "Cloud provider must be aws, gcp, or azure."
  }
}

variable "subnet_ids" {
  description = "Subnet IDs for database (AWS/Azure)"
  type        = list(string)
  default     = []
}

variable "vpc_id" {
  description = "VPC ID for database (AWS)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

# Outputs
output "db_endpoint" {
  description = "Database endpoint"
  value       = var.cloud_provider == "aws" ? aws_db_instance.main[0].endpoint : (var.cloud_provider == "gcp" ? google_sql_database_instance.main[0].connection_name : azurerm_postgresql_server.main[0].fqdn)
}

output "db_port" {
  description = "Database port"
  value       = 5432
}

output "db_name" {
  value = var.db_name
}

output "db_username" {
  value = var.db_username
}

output "connection_string" {
  description = "Database connection string"
  sensitive   = true
  value       = "postgresql://${var.db_username}:${var.db_password}@${var.cloud_provider == "aws" ? aws_db_instance.main[0].endpoint : (var.cloud_provider == "gcp" ? "${google_sql_database_instance.main[0].ip_address[0].ip_address}:5432" : "${azurerm_postgresql_server.main[0].fqdn}:5432")}/${var.db_name}"
}

