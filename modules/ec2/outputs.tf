output "instance_id" {
    description = "ID of the EC2 instance." 
    value = aws_instance.ec2_public.id
}

output "public_ip" {
  description = "Public IPv4 address of the EC2 instance."
  value       = aws_instance.ec2_public.public_ip
}

output "availability_zone" {
  description = "Availability Zone containing the EC2 instance."
  value       = aws_instance.ec2_public.id.availability_zone
}

output "ami_id" {
  description = "AMI selected dynamically for the EC2 instance."
  value       = aws_ami.al2023_ami_2023.id
}
