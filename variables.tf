variable "aws_region" {
  description = "AWS region in which the infrastructure is deployed (Paris - EU-West-3)."
  type        = string
  default     = "eu-west-3"
}

variable "name_prefix" {
  description = "Prefix used for resource names."
  type        = string
  default     = "wordpress"
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public EC2 subnet."
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_db_subnet_cidrs" {
  description = "CIDR blocks for the two private RDS subnets."
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

variable "enable_https" {
  description = "Whether port 443 should be opened."
  type        = bool
  default     = true
}

variable "ec2_instance_type" {
  description = "EC2 instance type for WordPress."
  type        = string
  default     = "t3.micro"
}

variable "rds_instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t3.micro"
}

variable "database_name" {
  description = "Name of the WordPress database."
  type        = string
  default     = "wordpress"
}

variable "database_username" {
  description = "Master username for the WordPress database."
  type        = string
  default     = "wordpress_admin"
}

variable "database_password" {
  description = "Master password for the WordPress RDS database."
  type        = string
  sensitive   = true

  validation {
    condition = (
      length(var.database_password) >= 8 &&
      length(var.database_password) <= 41 &&
      !can(regex("[/\"'@ ]", var.database_password))
    )

    error_message = "The MySQL password must contain 8–41 characters and cannot contain /, single quote, double quote, @, or spaces."
  }
}

variable "tags" {
  description = "Additional tags applied to AWS resources."
  type        = map(string)
  default     = {}
}