resource "aws_security_group" "iac_exercise_tasks_sg" {
  name        = "${var.project}-tasks-sg"
  description = "Allows ALB to reach ECS tasks"
  vpc_id      = aws_vpc.iac_exercise_vpc.id
  tags        = var.tags

  ingress {
    description     = "ALB to tasks"
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.iac_exercise_alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_service" "iac_exercise_app_service" {
  name            = "${var.project}-svc"
  cluster         = aws_ecs_cluster.iac_exercise_cluster.id
  task_definition = aws_ecs_task_definition.iac_exercise_app.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [for k, s in aws_subnet.iac_exercise_private : s.id]
    security_groups = [aws_security_group.iac_exercise_tasks_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.iac_exercise_app_tg.arn
    container_name   = var.project
    container_port   = var.container_port
  }

  deployment_controller {
    type = "ECS"
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  enable_execute_command = true  # ECS Exec

  lifecycle {
    ignore_changes = [task_definition] # so deploys via new revs don't need service changes
  }

  tags = var.tags
}

# For ECR access from tasks 

resource "aws_security_group" "task_sg" {
  name        = "${var.project}-ecr-sg"
  description = "Allows ECS tasks to reach ECR"
  vpc_id      = aws_vpc.iac_exercise_vpc.id
  tags        = var.tags

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.3.0.0/18"]
    description = "Allow outbound HTTPS to ECR"
  }
}
