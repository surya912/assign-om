# GCP GKE Configuration

resource "google_container_cluster" "main" {
  count    = var.cloud_provider == "gcp" ? 1 : 0
  name     = var.cluster_name
  location = var.region
  project  = var.project_id

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = var.network_name
  subnetwork = var.subnetwork_name

  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  node_config {
    machine_type = var.node_instance_type
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

resource "google_container_node_pool" "main" {
  count      = var.cloud_provider == "gcp" ? 1 : 0
  name       = "${var.cluster_name}-node-pool"
  location   = var.region
  cluster    = google_container_cluster.main[0].name
  node_count = var.node_count
  project    = var.project_id

  node_config {
    machine_type = var.node_instance_type
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}

variable "project_id" {
  description = "GCP Project ID"
  type        = string
  default     = ""
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

