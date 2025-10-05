# ALB security group (ingress from the world or your CIDRs)
resource "aws_security_group" "alb" {
  name        = "${var.project}-alb-sg"
  description = "ALB ingress/egress"
  vpc_id      = aws_vpc.iac_exercise_vpc.id
  tags        = var.tags

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.allowed_ingress_cidrs
  }

  # Optional HTTPS open if enabled
  dynamic "ingress" {
    for_each = var.enable_https ? [1] : []
    content {
      description = "HTTPS"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = var.allowed_ingress_cidrs
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Allow ONLY the ALB to reach your tasks on the app port
resource "aws_security_group_rule" "tasks_from_alb" {
  type                     = "ingress"
  description              = "ALB to tasks"
  from_port                = var.container_port
  to_port                  = var.container_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.tasks.id               # from sg.tf (existing)
  source_security_group_id = aws_security_group.alb.id
}
