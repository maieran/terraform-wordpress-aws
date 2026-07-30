output "volume_id" {
  description = "ID of the additional WordPress EBS volume."
  value       = aws_ebs_volume.wordpress_data.id
}

output "attachment_id" {
  description = "ID of the EC2 volume attachment."
  value       = aws_volume_attachment.wordpress_data.id
}