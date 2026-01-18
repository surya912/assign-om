# AWS RDS Configuration

resource "aws_db_subnet_group" "main" {
  count      = var.cloud_provider == "aws" ? 1 : 0
  name       = "${var.db_name}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = var.tags
}

resource "aws_db_instance" "main" {
  count              = var.cloud_provider == "aws" ? 1 : 0
  identifier         = var.db_name
  engine             = "postgres"
  engine_version     = "15.4"
  instance_class     = var.instance_class
  allocated_storage  = 20
  storage_encrypted  = true
  db_name            = var.db_name
  username           = var.db_username
  password           = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main[0].name
  vpc_security_group_ids = [aws_security_group.db[0].id]
  publicly_accessible    = false
  skip_final_snapshot    = true

  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "mon:04:00-mon:05:00"

  tags = var.tags
}

resource "aws_security_group" "db" {
  count       = var.cloud_provider == "aws" ? 1 : 0
  name        = "${var.db_name}-sg"
  description = "Security group for ${var.db_name} database"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"] # Allow from VPC
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

