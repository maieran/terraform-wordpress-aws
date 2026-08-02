variable "name_prefix" {
  description = "Prefix used for resource names."
  type        = string
}

variable "availability_zone" {
  description = "Availability Zone shared by the EC2 instance and EBS volume."
  type        = string
}

variable "instance_id" {
  description = "EC2 instance to which the EBS volume is attached."
  type        = string
}

variable "volume_size" {
  description = "Size of the persistent EBS volume in GiB"
  type        = number
  default     = 10

  validation {
    condition     = var.volume_size == 10
    error_message = "The assignment requires a 10-GiB additional EBS volume."
  }
}

variable "device_name" {
  description = "Requested Linux attachment name."
  type        = string
  default     = "/dev/sdf"
}

variable "tags" {
  description = "Tags applied to resources."
  type        = map(string)
  default     = {}
}