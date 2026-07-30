output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.our_vpc.id
}

output "public_subnet_id" {
  description = "ID of the public web subnet."
  value       = aws_subnet.public_sn.id
}

output "web_availability_zone" {
  description = "Availability Zone selected for EC2 and EBS."
  value       = aws_subnet.public_sn.availability_zone
}

output "selected_availability_zones" {
  description = "Two Availability Zones retrieved dynamically."
  value       = local.selected_azs
}

output "web_security_group_id" {
  description = "ID of the web server security group."
  value       = aws_security_group.web.id
}

output "private_db_subnet_ids" {
  description = "IDs of the private RDS subnets"
  value       = aws_subnet.private_db_sn[*].id
}

output "rds_security_group_id" {
  description = "Security group ID for RDS"
  value       = aws_security_group.rds.id
}

