output "endpoint" {
  description = "RDS endpoint in hostname:port format."
  value       = aws_db_instance.wordpress.endpoint
}

output "address" {
  description = "DNS hostname of the RDS instance."
  value       = aws_db_instance.wordpress.address
}

output "port" {
    description = "RDS MySQL port."
    value = aws_db_instance.wordpress-aws-db.port
}

output "db_instance_id" {
  description = "RDS DB instance identifier."
  value       = aws_db_instance.wordpress-aws-db.id
}