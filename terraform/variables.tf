variable "aws_region" {
  description = "AWS region to deploy to"
  type        = string
  default     = "us-east-1"
}

variable "dockerhub_username" {
  description = "Docker Hub username for building image names"
  type        = string
}