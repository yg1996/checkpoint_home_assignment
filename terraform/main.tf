provider "aws" {
  region = var.aws_region
}

# Use default VPC
data "aws_vpc" "default" {
  default = true
}

# Use existing public subnets (both AZs)
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "microservices-cluster"
}

# S3 Bucket
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "microservices_data" {
  bucket        = "microservices-${random_id.bucket_suffix.hex}"
  force_destroy = true
}

# SQS Queue
resource "aws_sqs_queue" "microservices_queue" {
  name = "microservices-queue"
}

# SSM Parameter for token
resource "aws_ssm_parameter" "api_token" {
  name  = "/microservices/token"
  type  = "SecureString"
  value = "your-secret-token"
}
