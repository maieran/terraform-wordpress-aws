// Public subnet AZ ──→ EBS volume AZ
resource "aws_ebs_volume" "wordpress_data" {
  availability_zone = var.availability_zone
  size              = var.volume_size
  type              = "gp3"
  encrypted         = true

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-wordpress-data"
  })
}

// EC2 instance ID ──→ EBS attachment
resource "aws_volume_attachment" "wordpress_data" {
  device_name = var.device_name
  volume_id   = aws_ebs_volume.wordpress_data.id
  instance_id = var.instance_id
}
