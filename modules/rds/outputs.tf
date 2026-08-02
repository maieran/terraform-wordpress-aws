output "endpoint" {
  description = "RDS endpoint in hostname:port format."
  value       = aws_db_instance.wordpress_aws_db.endpoint
}

output "address" {
  description = "DNS hostname of the RDS instance wihtout the port"
  value       = aws_db_instance.wordpress_aws_db.address
}

output "port" {
  description = "RDS MySQL port."
  value       = aws_db_instance.wordpress_aws_db.port
}

output "db_instance_id" {
  description = "RDS DB instance identifier."
  value       = aws_db_instance.wordpress_aws_db.id
}