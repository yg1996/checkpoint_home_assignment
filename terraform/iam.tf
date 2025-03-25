############################################
# IAM Role for ECS Task (Application Role)
############################################
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.prefix}-ecsTaskRole"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "ecs_task_policy" {
  name = "${var.prefix}-ecsTaskPolicy"
  role = aws_iam_role.ecs_task_role.id

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ],
        Resource = aws_sqs_queue.microservices_queue.arn
      },
      {
        Effect   = "Allow",
        Action   = ["s3:PutObject"],
        Resource = "${aws_s3_bucket.microservices_data.arn}/*"
      },
      {
        Effect   = "Allow",
        Action   = ["ssm:GetParameter"],
        Resource = aws_ssm_parameter.api_token.arn
      }
    ]
  })
}

############################################
# IAM Role for ECS Task Execution
############################################
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.prefix}-ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
