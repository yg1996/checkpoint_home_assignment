output "s3_bucket_name" {
  value = aws_s3_bucket.microservices_data.bucket
}

output "sqs_queue_url" {
  value = aws_sqs_queue.microservices_queue.id
}

output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value       = aws_lb.microservices_alb.dns_name
}

