locals {
  # Additional tags are merged with the mandatory project tags.
  common_tags = merge(
    var.tags,
    {
      Project     = var.name_prefix
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )

  # For example: wordpress-dev
  name_prefix = "${var.name_prefix}-${var.environment}"
}


# The networking module creates:
# - one VPC;
# - one public subnet for EC2;
# - an Internet Gateway and public route;
# - two private subnets for Multi-AZ RDS;
# - the EC2 and RDS security groups.
module "networking" {
  source = "./modules/networking"

  name_prefix             = local.name_prefix
  vpc_cidr                = var.vpc_cidr
  public_subnet_cidr      = var.public_subnet_cidr
  private_db_subnet_cidrs = var.private_db_subnet_cidrs
  enable_https            = var.enable_https
  tags                    = local.common_tags
}

# EC2 is placed in the public subnet and receives the web security group.
# Because the generated user-data script references the RDS address,
# Terraform waits until RDS has been created before creating EC2.
module "ec2" {
  source = "./modules/ec2"

  name_prefix       = local.name_prefix
  subnet_id         = module.networking.public_subnet_id
  security_group_id = module.networking.web_security_group_id
  instance_type     = var.ec2_instance_type



  # Terraform renders the installation script with the RDS connection values.
  # Referencing module.rds.address also ensures that RDS is created before EC2.
  #*.tftpl is the recommended naming pattern to use for your template files : see https://developer.hashicorp.com/terraform/language/functions/templatefile
  user_data = templatefile("${path.module}/install_wordpress.sh.tftpl", {
    db_host            = module.rds.address
    db_name            = var.database_name
    db_username        = var.database_username
    db_password_base64 = base64encode(var.database_password)
    enable_https       = tostring(var.enable_https)
  })

  tags = local.common_tags
}



# The volume uses the actual AZ of the EC2 instance. 
# This guarantees that EC2 and EBS are located in the same Availability Zone, which AWS requires.
# The EC2 instance ID creates the dependency:
# EC2 must exist before Terraform can attach the volume.
module "ebs" {
  source = "./modules/ebs"

  name_prefix = local.name_prefix

  # EBS volumes can only be attached to instances in the same AZ.
  availability_zone = module.ec2.availability_zone

  # Referencing the EC2 ID ensures EC2 exists before attachment.
  instance_id = module.ec2.instance_id

  # The 10 GiB is required for the volume attached to the EC2 instance
  volume_size = 10
  device_name = "/dev/sdf"

  tags = local.common_tags

}

# RDS uses the two private subnets created by the networking module.
# The RDS security group allows MySQL traffic only from EC2 resources attached to the web security group.
module "rds" {
  source = "./modules/rds"

  name_prefix           = local.name_prefix
  db_subnet_ids         = module.networking.private_db_subnet_ids
  rds_security_group_id = module.networking.rds_security_group_id

  instance_class    = var.rds_instance_class
  database_name     = var.database_name
  database_username = var.database_username
  database_password = var.database_password


  tags = local.common_tags
}
