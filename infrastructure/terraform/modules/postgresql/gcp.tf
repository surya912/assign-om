# GCP Cloud SQL Configuration

resource "google_sql_database_instance" "main" {
  count            = var.cloud_provider == "gcp" ? 1 : 0
  name             = var.db_name
  database_version = "POSTGRES_15"
  region           = var.region
  project          = var.project_id

  settings {
    tier              = var.instance_class
    availability_type = "ZONAL"

    backup_configuration {
      enabled                        = true
      start_time                     = "03:00"
      point_in_time_recovery_enabled = true
    }

    ip_configuration {
      ipv4_enabled    = false
      private_network = var.network_id
    }
  }

  deletion_protection = false
}

resource "google_sql_database" "main" {
  count    = var.cloud_provider == "gcp" ? 1 : 0
  name     = var.db_name
  instance = google_sql_database_instance.main[0].name
  project  = var.project_id
}

resource "google_sql_user" "main" {
  count    = var.cloud_provider == "gcp" ? 1 : 0
  name     = var.db_username
  instance = google_sql_database_instance.main[0].name
  password = var.db_password
  project  = var.project_id
}

variable "project_id" {
  description = "GCP Project ID"
  type        = string
  default     = ""
}

variable "network_id" {
  description = "GCP Network ID for private IP"
  type        = string
  default     = ""
}

