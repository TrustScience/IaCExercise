# ------------------------------------------------------------
# 1) Log group to receive ECS task state change events
# ------------------------------------------------------------
resource "aws_cloudwatch_log_group" "ecs_events" {
  name              = "/aws/events/${var.project}/ecs-task-events"
  retention_in_days = 30
  tags              = var.tags
}

# ------------------------------------------------------------
# 2) EventBridge rule: match ECS task STOPPED with pull errors
#    We look at stoppedReason for common image pull failures.
# ------------------------------------------------------------
resource "aws_cloudwatch_event_rule" "ecs_image_pull_errors" {
  name        = "${var.project}-ecs-image-pull-errors"
  description = "Match ECS task STOPPED events with Docker image pull errors"

  event_pattern = jsonencode({
    "source": ["aws.ecs"],
    "detail-type": ["ECS Task State Change"],
    "detail": {
      "lastStatus": ["STOPPED"],
      "stoppedReason": [
        { "prefix": "CannotPullContainerError" },
        { "prefix": "CannotCreateContainerError" },
        { "prefix": "Error response from daemon: pull access denied" }
      ]
    }
  })
  tags = var.tags
}

# ------------------------------------------------------------
# 3) IAM role so EventBridge can write into CloudWatch Logs
# ------------------------------------------------------------
data "aws_iam_policy_document" "events_to_logs_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "events_to_logs" {
  name               = "${var.project}-events-to-logs-role"
  assume_role_policy = data.aws_iam_policy_document.events_to_logs_assume.json
  tags               = var.tags
}

resource "aws_iam_role_policy" "events_to_logs" {
  name = "${var.project}-events-to-logs-policy"
  role = aws_iam_role.events_to_logs.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect: "Allow",
        Action: [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ],
        Resource: aws_cloudwatch_log_group.ecs_events.arn
      }
    ]
  })
}

# ------------------------------------------------------------
# 4) EventBridge target → CloudWatch Logs
# ------------------------------------------------------------
resource "aws_cloudwatch_event_target" "ecs_image_pull_errors_to_logs" {
  rule      = aws_cloudwatch_event_rule.ecs_image_pull_errors.name
  target_id = "send-to-cwlogs"
  arn       = aws_cloudwatch_log_group.ecs_events.arn
}

# ------------------------------------------------------------
# 5) Metric filter: produce a 1-count metric when pattern matches
# ------------------------------------------------------------
resource "aws_cloudwatch_log_metric_filter" "image_pull_error" {
  name           = "${var.project}-ImagePullErrors"
  log_group_name = aws_cloudwatch_log_group.ecs_events.name

  # Match common ECS image pull failures recorded by EventBridge
  # You can extend this with additional phrases if needed.
  pattern = "\"CannotPullContainerError\""

  metric_transformation {
    name      = "ImagePullErrors"
    namespace = "ECS/ImagePull"
    value     = "1"
  }
}

# ------------------------------------------------------------
# 6) Single CloudWatch alarm on that custom metric
#    Fires if >=1 error occurs in a 5-minute period.
# ------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "image_pull_error_alarm" {
  alarm_name          = "${var.project}-ECS-ImagePullErrors"
  alarm_description   = "ECS Docker image pull error detected (CannotPullContainerError / CannotCreateContainerError)"
  namespace           = "ECS/ImagePull"
  metric_name         = aws_cloudwatch_log_metric_filter.image_pull_error.metric_transformation[0].name
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 0
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"

  alarm_actions = length(var.alarm_sns_topic_arn) > 0 ? [var.alarm_sns_topic_arn] : []
  ok_actions    = length(var.alarm_sns_topic_arn) > 0 ? [var.alarm_sns_topic_arn] : []

  tags = var.tags
}
