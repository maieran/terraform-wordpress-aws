# Find the newest dynamically the most recent AMI available in the EU-West-3 region
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  # - x86_64 architecture, compatible with t3.micro
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.*-x86_64-gp2"]
  }

  # Explicitly prevent selection of an ARM-based AMI.
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  # Select an EBS-backed AMI using hardware-assisted virtualization.
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# Create the public EC2 instance on which WordPress will run.
resource "aws_instance" "ec2_public" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type

  # Assign a public IPv4 address so WordPress can be reached
  # from the internet through the web security group.
  associate_public_ip_address = true


  # Place EC2 in the public subnet created by the networking module, it determines the AZ automatically
  subnet_id = var.subnet_id

  # Attach the security group that allows HTTP and optional HTTPS
  # This argument expects a list, even though we attach only one group
  vpc_security_group_ids = [var.security_group_id]

  # Run the WordPress installation/bootstrap script when EC2 starts
  user_data = var.user_data

  # Recreate the instance when the bootstrap script changes
  # This ensures a modified installation script is executed again
  user_data_replace_on_change = true

  # Require Instance Metadata Service Version 2 (IMDSv2)
  # IMDSv2 protects metadata access by requiring session tokens
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  # Configure the EC2 operating-system/root disk
  # This is separate from the additional 10-GiB WordPress EBS volume
  root_block_device {
    # Encryption is temporarily disabled because the restricted training AWS
    # role cannot access the configured KMS key. Enable it when KMS access exists.
    encrypted   = false
    volume_size = 8
    volume_type = "gp3"
  }

  # Tags applied directly to the EC2 instance.
  tags = merge(var.tags, {
    Name  = "${var.name_prefix}-web"
    Owner = var.owner_name
  })

  # Tags applied to the root EBS volume created with the instance.
  volume_tags = merge(var.tags, {
    Name  = "${var.instance_name}-root"
    Owner = var.owner_name
  })
}

