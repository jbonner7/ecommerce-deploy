variable "storage" { default = 5 }
variable "skip_final_snapshot" { default = true }
variable "instance_class" { default = "db.t3.micro" }
variable "publicly_accessible" { default = false }
variable "engine_version" { default = null }
variable "port" { default = null }
variable "tags" { default = "" }
variable "parameter_group_family" { default = null }
variable "engine" {
  default = "postgres"

  validation {
    condition     = contains(["postgres", "mysql"], var.engine)
    error_message = "Valid values for engine: postgres or mysql"
  }
}


locals {
  new_tags = split(",", var.tags)
  engine_details = {
    "postgres" = {
      "engine"                 = "postgres"
      "engine_version"         = 14.8
      "port"                   = 5432
      "parameter_group_family" = "postgres14"
    }
    "mysql" = {
      "engine"                 = "mysql"
      "engine_version"         = "8.0.32"
      "port"                   = 3306
      "parameter_group_family" = "mysql8.0"
    }
  }
  final_version      = var.engine_version != null ? var.engine_version : local.engine_details[var.engine].engine_version
  final_port         = var.port != null ? var.port : local.engine_details[var.engine].port
  final_group_family = var.parameter_group_family != null ? var.parameter_group_family : local.engine_details[var.engine].parameter_group_family
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "order-subnet-grp"
  subnet_ids = module.vpc.private_subnets
  tags = merge({ "Name" = "order" }, {
    for t in local.new_tags : element(split("=", t), 0) => element(split("=", t), 1) if t != ""
  })
}

resource "aws_db_parameter_group" "db_parameter_group" {
  name   = "order-db-param-grp"
  family = local.final_group_family

  dynamic "parameter" {
    for_each = var.engine == "postgres" ? [1] : []
    content {
      name  = "log_connections"
      value = "1"
    }
  }

  tags = merge({ "Name" = "order" }, {
    for t in local.new_tags : element(split("=", t), 0) => element(split("=", t), 1) if t != ""
  })
}

resource "aws_security_group" "rds" {
  name   = "order-rds-sec-grp"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = local.final_port
    to_port     = local.final_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = local.final_port
    to_port     = local.final_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({ "Name" = "order" }, {
    for t in local.new_tags : element(split("=", t), 0) => element(split("=", t), 1) if t != ""
  })
}

resource "aws_db_instance" "rds" {
  identifier             = "order"
  instance_class         = var.instance_class
  allocated_storage      = var.storage
  engine                 = var.engine
  engine_version         = local.final_version
  username               = random_string.username.result
  password               = random_string.password.result
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.db_parameter_group.name
  publicly_accessible    = var.publicly_accessible
  skip_final_snapshot    = var.skip_final_snapshot
  tags = merge({ "Name" = "order" }, {
    for t in local.new_tags : element(split("=", t), 0) => element(split("=", t), 1) if t != ""
  })
}
