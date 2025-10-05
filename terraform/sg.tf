# Headless service: only egress to anywhere (for NAT/ECR/API).
resource "aws_security_group" "tasks" {
  name        = "${var.project}-tasks-sg"
  description = "ECS tasks egress"
  vpc_id      = aws_vpc.iac_exercise_vpc.id
  tags        = var.tags

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
