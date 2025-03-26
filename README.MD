# Project Title 🚀

## Description ℹ️
This project implements a system of two Docker microservices deployed on AWS ECS. The system integrates with AWS services such as an S3 bucket, an Elastic Load Balancer, and SQS. The infrastructure is fully defined using Terraform, and CI/CD processes are automated using GitHub Actions.

The assignment demonstrates:
- The deployment of a REST microservice (Microservice 1) behind an ELB.
- A worker microservice (Microservice 2) that periodically pulls messages from an SQS queue and uploads data to an S3 bucket.
- Infrastructure provisioning and configuration through Terraform.
- CI/CD automation for building, testing, and deploying Docker images.

## Project Structure 📁
- **microservice1_api**  
  - Contains the REST API that listens for HTTP requests, validates tokens from SSM Parameter Store, and publishes payloads to an SQS queue.
  - Files: `app.py`, `Dockerfile`, `requirements.txt`
  
- **microservice2_worker**  
  - Contains the worker process that pulls messages from the SQS queue and uploads the data to a specific path in an S3 bucket.
  - Files: `worker.py`, `Dockerfile`, `requirements.txt`
  
- **terraform**  
  - Contains the Terraform configuration files to provision the AWS infrastructure including ECS clusters, S3 bucket, SQS queue, IAM roles, and Elastic Load Balancer configurations.
  - Files: `main.tf`, `ecs.tf`, `iam.tf`, `outputs.tf`, `variables.tf`, along with state files.

- **README.MD**  
  - This documentation file.

## Requirements ✅
- AWS services: ECS, S3, SQS, ALB, SSM
- Python 3.x
- Docker
- Terraform
- CI/CD: GitHub Actions

## Prerequisites 🔑

Before running the CI/CD pipeline via GitHub Actions, make sure you have the following GitHub repository secrets configured:

- **AWS_ACCOUNT_ID**: Your AWS account ID.
- **AWS_REGION**: The AWS region you wish to deploy to.
- **AWS_ACCESS_KEY_ID**: Your AWS access key.
- **AWS_SECRET_ACCESS_KEY**: Your AWS secret key.
- **DOCKERHUB_USERNAME**: Your Docker Hub username.
- **DOCKERHUB_TOKEN**: Your Docker Hub access token.

## Installation and Setup 🛠️
1. **Clone the Repository:**
    ```bash
    git clone https://github.com/yg1996/checkpoint_home_assignment.git
    ```

2. **Navigate to the Project Directory:**
    ```bash
    cd checkpoint_home_assignment
    ```

3. **Setup Python Environment for Microservices:**
    - For Microservice 1:
      ```bash
      cd microservice1_api
      pip install -r requirements.txt
      cd ..
      ```
    - For Microservice 2:
      ```bash
      cd microservice2_worker
      pip install -r requirements.txt
      cd ..
      ```

4. **Terraform Setup:**
    - Navigate to the terraform directory:
      ```bash
      cd terraform
      ```
    - Initialize Terraform:
      ```bash
      terraform init
      ```
    - Provision the AWS environment:
      ```bash
      terraform apply -auto-approve
      ```
    - **Note:** Ensure that your AWS credentials and region are properly configured either locally or via your CI/CD pipeline.

5. **Docker and CI/CD:**
    - The CI/CD process is managed via GitHub Actions. The pipeline includes jobs to:
        - Build and push Docker images for both microservices.
        - Deploy the updated infrastructure via Terraform.
    - To test locally, you can build the Docker images using:
      ```bash
      docker build -t microservice1:latest ./microservice1_api
      docker build -t microservice2:latest ./microservice2_worker
      ```

## Usage 📡

- **For Microservice 1 (REST API):**
    - This service listens on a designated port behind the ELB.
    - It validates incoming tokens by comparing the request token with the token stored in AWS SSM Parameter Store and checks for date validity before publishing payload data to the SQS queue.
    - Once deployed, access this API via the ELB URL provided in your CI/CD output.

- **For Microservice 2 (SQS Worker):**
    - This service periodically polls the SQS queue for new messages and uploads them to a specific path in the S3 bucket.
    - The pull interval can be configured as needed.

## Testing the Deployment 🔍

After deployment, the GitHub Actions job output will display the following details:
