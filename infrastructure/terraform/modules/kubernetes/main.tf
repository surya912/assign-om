# Cloud-agnostic Kubernetes module
# Supports EKS, GKE, and AKS

variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
}

variable "region" {
  description = "Cloud provider region"
  type        = string
}

variable "node_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 2
}

variable "node_instance_type" {
  description = "Instance type for worker nodes"
  type        = string
  default     = "t3.medium"
}

variable "cloud_provider" {
  description = "Cloud provider: aws, gcp, or azure"
  type        = string
  validation {
    condition     = contains(["aws", "gcp", "azure"], var.cloud_provider)
    error_message = "Cloud provider must be aws, gcp, or azure."
  }
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

# Outputs
output "cluster_name" {
  value = var.cluster_name
}

output "cluster_endpoint" {
  description = "Kubernetes cluster endpoint"
  value       = var.cloud_provider == "aws" ? aws_eks_cluster.main[0].endpoint : (var.cloud_provider == "gcp" ? google_container_cluster.main[0].endpoint : azurerm_kubernetes_cluster.main[0].fqdn)
}

output "kubeconfig" {
  description = "Kubeconfig for cluster access"
  sensitive   = true
  value       = var.cloud_provider == "aws" ? aws_eks_cluster.main[0].kubeconfig : (var.cloud_provider == "gcp" ? "" : "")
}

