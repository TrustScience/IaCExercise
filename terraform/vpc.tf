resource "aws_vpc" "iac_exercise_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.tags, {
    Name    = "${var.project}-vpc"
    Project = var.project
  })
}

resource "aws_internet_gateway" "iac_exercise_igw" {
  vpc_id = aws_vpc.iac_exercise_vpc.id
  tags   = merge(var.tags, { Name = "${var.project}-igw" })
}

# resource "aws_cloudwatch_log_group" "iac_exercise_vpc_flow" {
#   name              = "/vpc/${var.project}/flow-logs"
#   retention_in_days = 30
#   tags              = var.tags
# }

# resource "aws_iam_role" "iac_exercise_iam_flowlogs" {
#   name               = "${var.project}-vpc-flowlogs-role"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect = "Allow"
#       Principal = { Service = "vpc-flow-logs.amazonaws.com" }
#       Action = "sts:AssumeRole"
#     }]
#   })
#   tags = var.tags
# }

# resource "aws_iam_role_policy" "iac_exercise_iam_role_policy_flowlogs" {
#   name = "${var.project}-vpc-flowlogs-policy"
#   role = aws_iam_role.iac_exercise_iam_flowlogs.id
#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [{
#       Effect = "Allow",
#       Action = ["logs:CreateLogStream","logs:PutLogEvents","logs:DescribeLogGroups","logs:DescribeLogStreams"],
#       Resource = "*"
#     }]
#   })
# }

# resource "aws_flow_log" "iac_exercise_aws_flowlogs" {
#   iam_role_arn    = aws_iam_role.iac_exercise_iam_flowlogs.arn
#   log_destination = aws_cloudwatch_log_group.iac_exercise_vpc_flow.arn
#   traffic_type    = "ALL"
#   vpc_id          = aws_vpc.iac_exercise_vpc.id
# }
