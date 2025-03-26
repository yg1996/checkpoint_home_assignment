provider "aws" {
  region = var.aws_region
}

# Generate a random prefix (10 lowercase alphanumeric characters)
resource "random_string" "prefix" {
  length  = 10
  special = false
  upper   = false
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

resource "aws_cloudwatch_log_group" "microservice1" {
  name              = "/ecs/microservice1"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "microservice2" {
  name              = "/ecs/microservice2"
  retention_in_days = 7
}

# ECS Cluster with a fixed name using the random prefix
resource "aws_ecs_cluster" "main" {
  name = "${random_string.prefix.result}-microservices-cluster"
}

# S3 Bucket (the bucket name must be globally unique; adjust if needed)
resource "aws_s3_bucket" "microservices_data" {
  bucket        = "${random_string.prefix.result}-microservices-data"
  force_destroy = true
}

# SQS Queue with a predictable name
resource "aws_sqs_queue" "microservices_queue" {
  name = "${random_string.prefix.result}-microservices-queue"
}

# SSM Parameter for token storage
resource "aws_ssm_parameter" "api_token" {
  name      = "/${random_string.prefix.result}/token"
  type      = "SecureString"
  value     = "your-secret-token"
}
