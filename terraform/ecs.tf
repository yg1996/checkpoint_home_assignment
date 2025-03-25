############################################
# Creating new ECR repositories
############################################
resource "aws_ecr_repository" "microservice1" {
  name                 = "${var.prefix}-microservice1"
  image_tag_mutability = "MUTABLE"
  
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "microservice2" {
  name                 = "${var.prefix}-microservice2"
  image_tag_mutability = "MUTABLE"
  
  image_scanning_configuration {
    scan_on_push = true
  }
}

############################################
# Security Group for the ALB
############################################
resource "aws_security_group" "alb_sg" {
  name        = "${var.prefix}-alb-sg"
  description = "Allow inbound HTTP traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow inbound HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

############################################
# Security Group for ECS Tasks
############################################
resource "aws_security_group" "ecs_tasks_sg" {
  name        = "${var.prefix}-ecs-tasks-sg"
  description = "Allow ECS tasks to communicate"
  vpc_id      = var.vpc_id

  # Allow traffic from the ALB on port 5000
  ingress {
    description     = "Allow traffic from ALB on port 5000"
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

############################################
# Application Load Balancer, Target Group, and Listener
############################################
resource "aws_lb" "microservices_alb" {
  name               = "${var.prefix}-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.subnet_ids
}

resource "aws_lb_target_group" "microservice1_tg" {
  name        = "${var.prefix}-microservice1-tg"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"  # For Fargate tasks
  health_check {
    path = "/submit"
    port = "traffic-port"
  }
}

resource "aws_lb_listener" "microservices_http_listener" {
  load_balancer_arn = aws_lb.microservices_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.microservice1_tg.arn
  }
}

############################################
# ECS Task Definition for Microservice 1
############################################
resource "aws_ecs_task_definition" "microservice1_taskdef" {
  family                   = "${var.prefix}-microservice1"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name  = "microservice1"
      image = "${aws_ecr_repository.microservice1.repository_url}:latest"
      portMappings = [
        {
          containerPort = 5000,
          hostPort      = 5000,
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "SQS_QUEUE_URL"
          value = aws_sqs_queue.microservices_queue.id
        },
        {
          name  = "TOKEN_PARAM_NAME"
          value = aws_ssm_parameter.api_token.name
        },
        {
          name  = "AWS_REGION"
          value = var.aws_region
        }
      ]
      logConfiguration = {
        logDriver = "awslogs",
        options   = {
          "awslogs-group"         = "/ecs/microservice1",
          "awslogs-region"        = var.aws_region,
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

############################################
# ECS Service for Microservice 1
############################################
resource "aws_ecs_service" "microservice1_service" {
  name             = "${var.prefix}-microservice1-service"
  cluster          = aws_ecs_cluster.main.id
  launch_type      = "FARGATE"
  desired_count    = 1
  platform_version = "1.4.0"

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [aws_security_group.ecs_tasks_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.microservice1_tg.arn
    container_name   = "microservice1"
    container_port   = 5000
  }

  task_definition = aws_ecs_task_definition.microservice1_taskdef.arn

  depends_on = [
    aws_lb_listener.microservices_http_listener
  ]
}

############################################
# ECS Task Definition for Microservice 2
############################################
resource "aws_ecs_task_definition" "microservice2_taskdef" {
  family                   = "${var.prefix}-microservice2"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name  = "microservice2"
      image = "${aws_ecr_repository.microservice2.repository_url}:latest"
      environment = [
        {
          name  = "SQS_QUEUE_URL"
          value = aws_sqs_queue.microservices_queue.id
        },
        {
          name  = "S3_BUCKET_NAME"
          value = aws_s3_bucket.microservices_data.bucket
        },
        {
          name  = "AWS_REGION"
          value = var.aws_region
        },
        {
          name  = "POLL_INTERVAL"
          value = "10"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs",
        options   = {
          "awslogs-group"         = "/ecs/microservice2",
          "awslogs-region"        = var.aws_region,
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

############################################
# ECS Service for Microservice 2
############################################
resource "aws_ecs_service" "microservice2_service" {
  name             = "${var.prefix}-microservice2-service"
  cluster          = aws_ecs_cluster.main.id
  launch_type      = "FARGATE"
  desired_count    = 1
  platform_version = "1.4.0"

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [aws_security_group.ecs_tasks_sg.id]
    assign_public_ip = true
  }

  task_definition = aws_ecs_task_definition.microservice2_taskdef.arn
}
