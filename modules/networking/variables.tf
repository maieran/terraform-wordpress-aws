variable "name_prefix" {
  description = "Prefix used for resources names."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC."
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block of the public web subnet."
  type        = string
}

variable "private_db_subnet_cidrs" {
  description = "Two CIDR blocks for private RDS subnets."
  type        = list(string)

  validation {
    condition     = length(var.private_db_subnet_cidrs) == 2
    error_message = "Two private RDS subnet CIDRs are required."
  }
}

variable "enable_https" {
  description = "Whether HTTPS ingress should be allowed."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags applied to resources."
  type        = map(string)
  default     = {}
}