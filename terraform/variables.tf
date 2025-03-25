variable "prefix" {
  description = "Prefix for resource names. Change this to avoid name collisions."
  type        = string
  default     = "demo"
}

variable "aws_region" {
  description = "AWS region to deploy to"
  type        = string
  default     = "us-east-1"
}
