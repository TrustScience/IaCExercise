resource "aws_security_group" "iac_exercise_alb_sg" {
  name        = "${var.project}-alb-sg"
  description = "ALB ingress"
  vpc_id      = aws_vpc.iac_exercise_vpc.id
  tags        = var.tags

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.iac_exercise_vpc.cidr_block] 
  }
}

resource "aws_lb" "iac_exercise_app_alb" {
  name                       = "${var.project}-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.iac_exercise_alb_sg.id]
  subnets                    = [for k, s in aws_subnet.iac_exercise_public : s.id]
  idle_timeout               = var.alb_idle_timeout
  enable_deletion_protection = false
  tags                       = var.tags
}

resource "aws_lb_target_group" "iac_exercise_app_tg" {
  name        = "${var.project}-tg"
  port        = var.container_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.iac_exercise_vpc.id

  health_check {
    path                = var.health_check_path
    healthy_threshold   = 2
    unhealthy_threshold = 5
    timeout             = 5
    interval            = 30
    matcher             = "200-399"
  }

  tags = var.tags
}

resource "aws_lb_listener" "iac_exercise_http" {
  load_balancer_arn = aws_lb.iac_exercise_app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.iac_exercise_app_tg.arn
  }
}
