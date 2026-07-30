output "endpoint" {
    description = "RDS connection endpoint including the port."
    value = aws_db_instance.wordpress-aws-db.endpoint
}

output "address"{
    description = "RDS hostname without the port"
    value = aws_db_instance.wordpress-aws-db.address
}

output "port" {
    description = "RDS MySQL port."
    value = aws_db_instance.wordpress-aws-db.port
}

output "db_instance_id" {
  description = "RDS DB instance identifier."
  value       = aws_db_instance.wordpress-aws-db.id
}