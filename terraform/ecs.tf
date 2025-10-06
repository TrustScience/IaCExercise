resource "aws_ecs_cluster" "iac_exercise_cluster" {
  name = "${var.project}-cluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  tags = var.tags
}

# Capacity providers so we can mix On-Demand and Spot
resource "aws_ecs_cluster_capacity_providers" "iac_exercise_cluster_capacity_provider" {
  cluster_name = aws_ecs_cluster.iac_exercise_cluster.name
  capacity_providers = var.enable_fargate_spot ? ["FARGATE", "FARGATE_SPOT"] : ["FARGATE"]
  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
  }
}

locals {
  container_def = {
    name      = var.project
    image     = var.container_image
    essential = true
    portMappings = [{
      containerPort = var.container_port
      hostPort      = var.container_port
      protocol      = "tcp"
      appProtocol   = "http"
    }]
    environment = [
      for k, v in var.env_vars : { name = k, value = v }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.iac_exercise_app_log.name
        awslogs-region        = var.region
        awslogs-stream-prefix = var.project
      }
    }
  }
}

resource "aws_ecs_task_definition" "iac_exercise_app" {
  family                   = "${var.project}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = tostring(var.cpu)
  memory                   = tostring(var.memory)
  execution_role_arn       = aws_iam_role.iac_exercise_task_execution.arn
  task_role_arn            = aws_iam_role.iac_exercise_task_role.arn
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([local.container_def])
  tags                  = var.tags
}

