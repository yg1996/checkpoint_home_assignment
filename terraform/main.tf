provider "aws" {
  region = var.aws_region
}

# Lookup the default VPC
data "aws_vpc" "default" {
  default = true
}

# Lookup all subnets in the default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# ECS Cluster with a fixed name using the prefix variable
resource "aws_ecs_cluster" "main" {
  name = "${var.prefix}-microservices-cluster"
}

# S3 Bucket (the bucket name must be globally unique; adjust if needed)
resource "aws_s3_bucket" "microservices_data" {
  bucket        = "${var.prefix}-microservices-data"
  force_destroy = true
}

# SQS Queue with a predictable name
resource "aws_sqs_queue" "microservices_queue" {
  name = "${var.prefix}-microservices-queue"
}

# SSM Parameter for token storage
resource "aws_ssm_parameter" "api_token" {
  name      = "/${var.prefix}/token"
  type      = "SecureString"
  value     = "your-secret-token"
  overwrite = true
}
