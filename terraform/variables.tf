variable "prefix" {
  description = "Prefix for resource names. Change this to avoid name collisions."
  type        = string
  default     = "demo"
}

variable "aws_region" {
  description = "AWS region to deploy to."
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "The VPC ID to use for ECS and other resources. (Pass this via TF_VAR_vpc_id)"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs to use for the ECS cluster (e.g., public subnets). (Pass this via TF_VAR_subnet_ids as a comma-separated list)"
  type        = list(string)
}
