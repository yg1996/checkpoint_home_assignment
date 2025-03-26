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

Before running the CI/CD pipeline via GitHub Actions or deploying via Terraform locally, ensure:
- **GitHub Repository Secrets:**  
  Configure these in your repository settings:
  - **AWS_ACCOUNT_ID:** Your AWS account ID.
  - **AWS_REGION:** The AWS region you wish to deploy to.
  - **AWS_ACCESS_KEY_ID:** Your AWS access key.
  - **AWS_SECRET_ACCESS_KEY:** Your AWS secret key.
  - **DOCKERHUB_USERNAME:** Your Docker Hub username.
  - **DOCKERHUB_TOKEN:** Your Docker Hub access token.
- **AWS CLI Credentials (for local deployments):**  
  Ensure your local AWS CLI is configured with the correct credentials.

## Installation and Setup 🛠️

### Option 1: Clone & Push to a New Remote GitHub Repository
1. **Clone the Repository:**
    ```bash
    git clone https://github.com/yg1996/checkpoint_home_assignment.git
    ```
2. **Navigate to the Project Directory:**
    ```bash
    cd checkpoint_home_assignment
    ```
3. **Configure GitHub Repository Secrets:**  
   In your new remote repository’s settings, add all the required secrets as listed in the Prerequisites section.
4. **Push to the New Remote Repository:**  
   If you need to change the remote URL:
    ```bash
    git remote set-url origin <NEW_REMOTE_REPO_URL>
    git push -u origin main
    ```
   On push, the GitHub Actions workflow will trigger and deploy your application.

### Option 2: Deploy Using Terraform from the Local Machine
1. **Clone the Repository:**
    ```bash
    git clone https://github.com/yg1996/checkpoint_home_assignment.git
    ```
2. **Navigate to the Terraform Directory:**
    ```bash
    cd checkpoint_home_assignment/terraform
    ```
3. **Initialize Terraform:**
    ```bash
    terraform init
    ```
4. **Deploy the AWS Infrastructure:**
    ```bash
    terraform apply -auto-approve
    ```
   Ensure your AWS CLI is configured locally (using the same credentials as specified in the Prerequisites) so Terraform can provision resources correctly.

## Usage 📡

- **For Microservice 1 (REST API):**
    - This service listens on a designated port behind the ELB.
    - It validates incoming tokens by comparing the request token with the token stored in AWS SSM Parameter Store and checks for date validity before publishing payload data to the SQS queue.
    - Once deployed, access this API via the ELB URL provided in your CI/CD output.

- **For Microservice 2 (SQS Worker):**
    - This service periodically polls the SQS queue for new messages and uploads them to a specific path in the S3 bucket.
    - The pull interval can be configured as needed.

## Testing the Deployment 🔍

After deployment, the GitHub Actions job output will display details similar to:

alb_dns_name = "<ALB_DNS_NAME>" s3_bucket_name = "<S3_BUCKET_NAME>" sqs_queue_url = "<SQS_QUEUE_URL>"

Use the **alb_dns_name** to test the endpoints:

**Test Microservice 1 (Submit Request):**
```bash
curl -v -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "data": {
      "email_subject": "Happy new year!",
      "email_sender": "John Doe",
      "email_timestream": "1693561101",
      "email_content": "Just want to say... Happy new year!!!"
    },
    "token": "your-secret-token"
  }' \
  http://<ALB_DNS_NAME>/submit
```
Replace <ALB_DNS_NAME> with the actual value from your deployment output.

**Test Health Endpoint:**
```bash
curl -v http://<ALB_DNS_NAME>/health
```
Again, replace <ALB_DNS_NAME> with the real DNS name provided in the CI/CD output.


## Contact 📧
For questions or suggestions, please contact: yg19967@gmail.com.

