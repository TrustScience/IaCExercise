# resource "aws_iam_role" "iac_exercise_task_execution" {
#   name               = "${var.project}-ecsTaskExecutionRole"
#   assume_role_policy = data.aws_iam_policy_document.iac_exercise_ecs_tasks_assume.json
#   tags               = var.tags
# }

# resource "aws_iam_role" "iac_exercise_task_role" {
#   name               = "${var.project}-ecsTaskRole"
#   assume_role_policy = data.aws_iam_policy_document.iac_exercise_ecs_tasks_assume.json
#   tags               = var.tags
# }

# data "aws_iam_policy_document" "iac_exercise_ecs_tasks_assume" {
#   statement {
#     effect = "Allow"
#     principals {
#       type        = "Service"
#       identifiers = ["ecs-tasks.amazonaws.com"]
#     }
#     actions = ["sts:AssumeRole"]
#   }
# }

# resource "aws_iam_role_policy_attachment" "iac_exercise_exec_ecr" {
#   role       = aws_iam_role.iac_exercise_task_execution.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
# }

# # Ensure the execution role can read from ECR (pull images). The managed
# # AmazonECSTaskExecutionRolePolicy should normally cover this, but add the
# # explicit ReadOnly policy to be explicit and avoid pull errors.
# resource "aws_iam_role_policy_attachment" "iac_exercise_exec_ecr_readonly" {
#   role       = aws_iam_role.iac_exercise_task_execution.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
# }

# # Provide the running task (container) with read-only S3 access by default.
# # This is attached to the task role (not the execution role) since it's used
# # by the application code inside the container.
# resource "aws_iam_role_policy_attachment" "iac_exercise_task_s3_readonly" {
#   role       = aws_iam_role.iac_exercise_task_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
# }

# # In some deployments the execution and task role wiring may be swapped or
# # misconfigured. Attach the execution and ECR read policies to the task role
# # as well so the role actually used to pull images has the required perms.
# resource "aws_iam_role_policy_attachment" "iac_exercise_task_exec_policy" {
#   role       = aws_iam_role.iac_exercise_task_role.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
# }

# resource "aws_iam_role_policy_attachment" "iac_exercise_task_exec_ecr_readonly" {
#   role       = aws_iam_role.iac_exercise_task_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
# }


# ECS tasks assume this principal
data "aws_iam_policy_document" "ecs_tasks_assume" {
  statement {
    effect = "Allow"
    principals { 
        type = "Service" 
        identifiers = ["ecs-tasks.amazonaws.com"] 
    }
    actions   = ["sts:AssumeRole"]
  }
}

# Role used by the agent to pull from ECR and push logs
resource "aws_iam_role" "task_execution" {
  name               = "${var.project}-ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "exec_managed" {
  role       = aws_iam_role.task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

// Ensure the execution role can read from ECR (pull images). The managed
// AmazonECSTaskExecutionRolePolicy normally covers image pull permissions,
// but adding the explicit ECR read-only policy avoids permission gaps.
resource "aws_iam_role_policy_attachment" "exec_ecr_readonly" {
  role       = aws_iam_role.task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Add explicit ECR pull-only policy to the execution role to ensure
# it can pull images from ECR.
resource "aws_iam_role_policy_attachment" "exec_ecr_pullonly" {
  role       = aws_iam_role.task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
}

# Optional: app's task role (for runtime AWS API calls)
resource "aws_iam_role" "task" {
  name               = "${var.project}-ecsTaskRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume.json
  tags               = var.tags
}

# Least-privilege read of specific SSM parameters (if used)
resource "aws_iam_policy" "task_ssm" {
  count  = length(var.ssm_param_names) > 0 ? 1 : 0
  name   = "${var.project}-task-ssm"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid    = "GetParams",
      Effect = "Allow",
      Action = ["ssm:GetParameter","ssm:GetParameters","ssm:GetParametersByPath"],
      Resource = [
        for p in var.ssm_param_names :
        "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter${p}"
      ]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "task_ssm_attach" {
  count      = length(var.ssm_param_names) > 0 ? 1 : 0
  role       = aws_iam_role.task.name
  policy_arn = aws_iam_policy.task_ssm[0].arn
}
