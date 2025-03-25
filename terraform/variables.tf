variable "prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "demo1"
}

variable "aws_region" {
  description = "AWS region to deploy to"
  type        = string
  default     = "us-east-1"
}
