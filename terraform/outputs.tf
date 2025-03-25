output "s3_bucket_name" {
  value = aws_s3_bucket.microservices_data.bucket
}

output "sqs_queue_url" {
  value = aws_sqs_queue.microservices_queue.id
}
