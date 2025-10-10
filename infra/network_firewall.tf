# checkov:skip=CKV_AWS_345:Using default encryption for this exercise, CMK not required
resource "aws_networkfirewall_rule_group" "allow_http_https" {
  name        = "${var.project_name}-allow-http-https"
  type        = "STATEFUL"
  capacity    = 100
  description = "Allow HTTP and HTTPS traffic, block everything else"

  rule_group {
    rules_source {
      stateful_rule {
        action = "PASS"
        header {
          destination      = "ANY"
          destination_port = "80"
          direction        = "FORWARD"
          protocol         = "TCP"
          source           = "ANY"
          source_port      = "ANY"
        }
        rule_option {
          keyword = "sid:1"
        }
      }

      stateful_rule {
        action = "PASS"
        header {
          destination      = "ANY"
          destination_port = "443"
          direction        = "FORWARD"
          protocol         = "TCP"
          source           = "ANY"
          source_port      = "ANY"
        }
        rule_option {
          keyword = "sid:2"
        }
      }
    }

    # Default action: DROP all other traffic
    stateful_rule_options {
      rule_order = "STRICT_ORDER"
    }
  }

  tags = {
    Name = "${var.project_name}-allow-http-https-rules"
  }
}

# checkov:skip=CKV_AWS_346:Using default encryption for this exercise, CMK not required
resource "aws_networkfirewall_firewall_policy" "main" {
  name = "${var.project_name}-firewall-policy"

  firewall_policy {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]

    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.allow_http_https.arn
      priority     = 1
    }

    stateful_engine_options {
      rule_order = "STRICT_ORDER"
    }

    # Block all traffic that doesn't match the rules
    stateful_default_actions = ["aws:drop_strict"]
  }

  tags = {
    Name = "${var.project_name}-firewall-policy"
  }
}

# checkov:skip=CKV_AWS_345:Using default encryption for this exercise, CMK not required
# checkov:skip=CKV_AWS_344:Deletion protection disabled for easier cleanup in exercise environment
resource "aws_networkfirewall_firewall" "main" {
  name                = "${var.project_name}-firewall"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.main.arn
  vpc_id              = aws_vpc.main.id

  # Deploy firewall endpoints in dedicated firewall subnets
  dynamic "subnet_mapping" {
    for_each = aws_subnet.firewall[*].id
    content {
      subnet_id = subnet_mapping.value
    }
  }

  tags = {
    Name = "${var.project_name}-network-firewall"
  }
}

# checkov:skip=CKV_AWS_338:7-day retention is sufficient for this exercise
resource "aws_cloudwatch_log_group" "network_firewall" {
  name              = "/aws/networkfirewall/${var.project_name}"
  retention_in_days = 7
  kms_key_id        = aws_kms_key.cloudwatch_logs.arn

  tags = {
    Name = "${var.project_name}-firewall-logs"
  }

  depends_on = [aws_kms_key_policy.cloudwatch_logs]
}

resource "aws_networkfirewall_logging_configuration" "main" {
  firewall_arn = aws_networkfirewall_firewall.main.arn

  logging_configuration {
    log_destination_config {
      log_destination = {
        logGroup = aws_cloudwatch_log_group.network_firewall.name
      }
      log_destination_type = "CloudWatchLogs"
      log_type             = "ALERT"
    }

    log_destination_config {
      log_destination = {
        logGroup = aws_cloudwatch_log_group.network_firewall.name
      }
      log_destination_type = "CloudWatchLogs"
      log_type             = "FLOW"
    }
  }
}
