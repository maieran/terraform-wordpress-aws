resource "aws_db_instance" "wordpress-aws-db" {
  identifier = "${var.name_prefix}-mysql-rds"

  engine         = "mysql"
  engine_version = "8.0"
  instance_class = var.instance_class

  db_name  = var.database_name
  username = var.database_username
  password = var.database_password

  allocated_storage = 20
  storage_type      = "gp3"
  storage_encrypted = true

  publicly_accessible = false
  multi_az            = true

  db_subnet_group_name   = aws_db_subnet_group.wordpress.name
  vpc_security_group_ids = [var.rds_security_group_id]

  backup_retention_period = 1
  skip_final_snapshot     = true

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-mysql-rds"
  }) 
}

resource "aws_db_subnet_group" "wordpress" {
    name = "${var.name_prefix}-db-subnets"
    subnet_ids = var.db_subnet_ids

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-db-subnets"
  })
}