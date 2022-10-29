resource "aws_security_group" "vm_booking_db_sg" {
  name        = "vm-booking-db-sg"
  description = "vm-booking-db-sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.ec2_sg_id]
  }

  tags = {
    Name      = "vm-booking-db-sg"
    CreatedBy = var.created_by
  }
}

resource "aws_db_subnet_group" "db_subnet_group" {
  subnet_ids = [var.subnets[0], var.subnets[1]]

  tags = {
    CreatedBy = var.created_by
  }
}

resource "random_string" "random_db_pg" {
  length  = 3
  special = false
  upper   = false
  number  = false
}

resource "aws_db_parameter_group" "db_param_group" {
  name   = "rds-pg-${random_string.random_db_pg.result}"
  family = "postgres9.6"

  tags = {
    CreatedBy = var.created_by
  }
}

resource "random_pet" "rds_username" {
  length = 1
}

resource "random_string" "random_ssm_db_username" {
  length  = 3
  special = false
  upper   = false
  number  = false
}

resource "aws_ssm_parameter" "db_username" {
  name  = "vm_booking_app.db_username_${random_string.random_ssm_db_username.result}"
  type  = "String"
  value = random_pet.rds_username.id

  tags = {
    CreatedBy = var.created_by
  }
}

resource "random_password" "rds_password" {
  length  = 8
  special = false
}

resource "random_string" "random_ssm_db_password" {
  length  = 3
  special = false
  upper   = false
  number  = false
}

resource "aws_ssm_parameter" "db_password" {
  name  = "vm_booking_app.db_password_${random_string.random_ssm_db_password.result}"
  type  = "SecureString"
  value = random_password.rds_password.result

  tags = {
    CreatedBy = var.created_by
  }
}

resource "aws_db_instance" "db" {
  identifier_prefix       = "vm-booking-db-"
  allocated_storage       = var.db_instance_storage_size
  storage_type            = "gp2"
  engine                  = "postgres"
  engine_version          = "9.6.20"
  instance_class          = var.db_instance_type
  name                    = "vm_booking"
  username                = random_pet.rds_username.id
  password                = random_password.rds_password.result
  db_subnet_group_name    = aws_db_subnet_group.db_subnet_group.name
  parameter_group_name    = aws_db_parameter_group.db_param_group.name
  backup_retention_period = 2
  skip_final_snapshot     = true
  apply_immediately       = true

  vpc_security_group_ids = [aws_security_group.vm_booking_db_sg.id]

  tags = {
    CreatedBy = var.created_by
  }
}

resource "random_string" "random_ssm_db_host" {
  length  = 3
  special = false
  upper   = false
  number  = false
}

resource "aws_ssm_parameter" "db_host" {
  name  = "vm_booking_app.db_host_${random_string.random_ssm_db_host.result}"
  type  = "String"
  value = aws_db_instance.db.address

  tags = {
    CreatedBy = var.created_by
  }
}
