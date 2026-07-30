variable "name_prefix" {
  description = "Prefix used for resource names."
  type        = string
}

variable "subnet_id" {
  description = "Public subnet in which the instance is created."
  type        = string
}

variable "security_group_id" {
  description = "Security group attached to the instance."
  type        = string
}

/*
variable "availability_zone" {
  description = "Required Availability Zone for the instance."
  type        = string
} */

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "user_data" {
  description = "Bootstrap script used to install WordPress."
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Tags applied to resources."
  type        = map(string)
  default     = {}
}
