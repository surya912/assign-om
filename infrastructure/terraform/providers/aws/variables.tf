variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "idea-board"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "node_count" {
  description = "Number of Kubernetes worker nodes"
  type        = number
  default     = 2
}

variable "node_instance_type" {
  description = "Instance type for Kubernetes nodes"
  type        = string
  default     = "t3.medium"
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
  description = "Database instance class"
  type        = string
  default     = "db.t3.micro"
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

