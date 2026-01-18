variable "gcp_project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "gcp_region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "idea-board"
}

variable "network_name" {
  description = "GCP Network name"
  type        = string
  default     = "default"
}

variable "subnetwork_name" {
  description = "GCP Subnetwork name"
  type        = string
  default     = ""
}

variable "network_id" {
  description = "GCP Network ID for Cloud SQL"
  type        = string
  default     = ""
}

variable "node_count" {
  description = "Number of Kubernetes worker nodes"
  type        = number
  default     = 2
}

variable "node_instance_type" {
  description = "Machine type for Kubernetes nodes"
  type        = string
  default     = "e2-medium"
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "ideaboard"
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

variable "db_instance_class" {
  description = "Database instance tier"
  type        = string
  default     = "db-f1-micro"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Project     = "IdeaBoard"
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}

