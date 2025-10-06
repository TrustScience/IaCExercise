resource "aws_iam_role" "iac_exercise_task_execution" {
  name               = "${var.project}-ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.iac_exercise_ecs_tasks_assume.json
  tags               = var.tags
}

resource "aws_iam_role" "iac_exercise_task_role" {
  name               = "${var.project}-ecsTaskRole"
  assume_role_policy = data.aws_iam_policy_document.iac_exercise_ecs_tasks_assume.json
  tags               = var.tags
}

data "aws_iam_policy_document" "iac_exercise_ecs_tasks_assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "iac_exercise_exec_ecr" {
  role       = aws_iam_role.iac_exercise_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Ensure the execution role can read from ECR (pull images). The managed
# AmazonECSTaskExecutionRolePolicy should normally cover this, but add the
# explicit ReadOnly policy to be explicit and avoid pull errors.
resource "aws_iam_role_policy_attachment" "iac_exercise_exec_ecr_readonly" {
  role       = aws_iam_role.iac_exercise_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Provide the running task (container) with read-only S3 access by default.
# This is attached to the task role (not the execution role) since it's used
# by the application code inside the container.
resource "aws_iam_role_policy_attachment" "iac_exercise_task_s3_readonly" {
  role       = aws_iam_role.iac_exercise_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}


# Add explicit ECR pull-only policy to the execution role to ensure
# it can pull images from ECR.
resource "aws_iam_role_policy_attachment" "exec_ecr_pullonly" {
  role       = aws_iam_role.iac_exercise_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
}

