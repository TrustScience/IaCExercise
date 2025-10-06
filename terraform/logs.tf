resource "aws_cloudwatch_log_group" "iac_exercise_app_log" {
  name              = "/ecs/${var.project}"
  retention_in_days = 30
  tags              = var.tags
}

locals {
  flow_log_group_name = "/vpc/${var.project}/flow-logs"
}

# CloudWatch log group for VPC Flow Logs
resource "aws_cloudwatch_log_group" "vpc_flow" {
  count             = var.flow_logs_enabled ? 1 : 0
  name              = local.flow_log_group_name
  retention_in_days = var.flow_logs_retention_days
  tags              = var.tags
}

# IAM role that VPC Flow Logs service assumes to write to CW Logs
resource "aws_iam_role" "flowlogs" {
  count = var.flow_logs_enabled ? 1 : 0
  name  = "${var.project}-vpc-flowlogs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "vpc-flow-logs.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}

# Least-privilege policy for writing to the specific log group
resource "aws_iam_role_policy" "flowlogs" {
  count = var.flow_logs_enabled ? 1 : 0
  name  = "${var.project}-vpc-flowlogs-policy"
  role  = aws_iam_role.flowlogs[0].id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ],
        Resource = aws_cloudwatch_log_group.vpc_flow[0].arn
      }
    ]
  })
}

# VPC Flow Log resource
resource "aws_flow_log" "this" {
  count = var.flow_logs_enabled ? 1 : 0

  log_destination_type = "cloud-watch-logs"
  log_destination      = aws_cloudwatch_log_group.vpc_flow[0].arn
  iam_role_arn         = aws_iam_role.flowlogs[0].arn
  traffic_type         = var.flow_logs_traffic_type

  vpc_id = aws_vpc.iac_exercise_vpc.id

  tags = merge(var.tags, { Name = "${var.project}-vpc-flowlogs" })

  depends_on = [
    aws_cloudwatch_log_group.vpc_flow,
    aws_iam_role_policy.flowlogs
  ]
}
