# Azure Database for PostgreSQL Configuration

resource "azurerm_postgresql_server" "main" {
  count                           = var.cloud_provider == "azure" ? 1 : 0
  name                            = "${var.db_name}-server"
  location                        = var.region
  resource_group_name             = var.resource_group_name
  sku_name                        = var.instance_class
  storage_mb                      = 51200
  backup_retention_days           = 7
  geo_redundant_backup_enabled    = false
  auto_grow_enabled               = true
  administrator_login             = var.db_username
  administrator_login_password    = var.db_password
  version                         = "15.0"
  ssl_enforcement_enabled         = true
  ssl_minimal_tls_version_enforced = "TLS1_2"

  tags = var.tags
}

resource "azurerm_postgresql_database" "main" {
  count               = var.cloud_provider == "azure" ? 1 : 0
  name                = var.db_name
  resource_group_name = var.resource_group_name
  server_name          = azurerm_postgresql_server.main[0].name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}

resource "azurerm_postgresql_firewall_rule" "main" {
  count               = var.cloud_provider == "azure" ? 1 : 0
  name                = "${var.db_name}-firewall"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_postgresql_server.main[0].name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

variable "resource_group_name" {
  description = "Azure Resource Group name"
  type        = string
  default     = ""
}

