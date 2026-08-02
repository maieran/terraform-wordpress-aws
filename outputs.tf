output "wordpress_public_ip" {
  description = "Public IP address of the WordPress server."
  value       = module.ec2.public_ip
}

output "wordpress_http_url" {
  description = "HTTP address of the WordPress website."
  value       = "http://${module.ec2.public_ip}"
}

output "wordpress_https_url" {
  description = "HTTPS address. The browser warns because the included certificate is self-signed."
  value       = var.enable_https ? "https://${module.ec2.public_ip}" : null
}

output "ec2_instance_id" {
  description = "ID of the WordPress EC2 instance."
  value       = module.ec2.instance_id
}

output "selected_ami_id" {
  description = "Most recent matching Amazon Linux 2 AMI selected automatically."
  value       = module.ec2.ami_id
}

output "selected_availability_zones" {
  description = "Available zones selected automatically for the deployment."
  value       = module.networking.selected_availability_zones
}

output "rds_endpoint" {
  description = "Private endpoint of the Multi-AZ MySQL database."
  value       = module.rds.endpoint
}

output "ebs_volume_id" {
  description = "ID of the 10-GiB persistent EBS volume."
  value       = module.ebs.volume_id
}