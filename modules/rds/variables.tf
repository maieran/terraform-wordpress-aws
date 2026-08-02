variable "name_prefix" {
  description = "Prefix that is used for resource names."
  type        = string
}

variable "db_subnet_ids" {
  description = "Private subnet IDs in two distinct AZs"
  type        = list(string)

  validation {
    condition     = length(var.db_subnet_ids) >= 2
    error_message = "RDS(MySQL) requires subnets in at least two AZs."
  }
}

variable "rds_security_group_id" {
  description = "Security group attached to RDS."
  type        = string
}

variable "instance_class" {
  description = "RDS DB instance class."
  type        = string
  default     = "db.t3.micro"
}

variable "database_name" {
  description = "Initial MySQL database name."
  type        = string
}

variable "database_username" {
  description = "RDS master username."
  type        = string
}

variable "database_password" {
  description = "RDS master password."
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Tags applied to resources."
  type        = map(string)
  default     = {}
}