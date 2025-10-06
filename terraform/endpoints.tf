// Note: S3 gateway endpoint omitted because route table resources are
// currently not managed in this module. If you want S3 gateway endpoints,
// re-enable the route table resources in `routes.tf` and add a gateway
// endpoint here.

// Common interface endpoints (landed into private subnets). We include
// ECR interface endpoints by default unless explicitly disabled so tasks in
// private subnets can pull images without NAT.
locals {
  base_interface_endpoint_services = [
    "com.amazonaws.${var.region}.ssm",
    "com.amazonaws.${var.region}.ssmmessages",
    "com.amazonaws.${var.region}.ec2messages",
    "com.amazonaws.${var.region}.logs",
    "com.amazonaws.${var.region}.sts",
    "com.amazonaws.${var.region}.secretsmanager",
    "com.amazonaws.${var.region}.kms",
    "com.amazonaws.${var.region}.ec2",
  ]

  ecr_services = [for svc in ["ecr.api", "ecr.dkr"] : "com.amazonaws.${var.region}.${svc}"]

  interface_endpoint_services = var.disable_ecr_interface_endpoints ? local.base_interface_endpoint_services : concat(local.base_interface_endpoint_services, local.ecr_services)
}

// Security group for interface endpoints. Allow tasks to reach endpoints on HTTPS.
resource "aws_security_group" "iac_exercise_endpoints" {
  count  = var.create_interface_endpoints ? 1 : 0
  name   = "${var.project}-vpce-sg"
  vpc_id = aws_vpc.iac_exercise_vpc.id

  // Allow private tasks to reach the endpoints over HTTPS
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.task_sg.id] // tasks security group
    // Also allow the public and private subnet CIDRs as a fallback
    cidr_blocks     = concat(
      [for s in aws_subnet.iac_exercise_public : s.cidr_block],
      [for s in aws_subnet.iac_exercise_private : s.cidr_block]
    )
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.project}-vpce-sg" })
}

// Create interface endpoints for the selected services into private subnets
resource "aws_vpc_endpoint" "iac_exercise_interfaces" {
  for_each            = var.create_interface_endpoints ? toset(local.interface_endpoint_services) : toset([])
  vpc_id              = aws_vpc.iac_exercise_vpc.id
  service_name        = each.value
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [for k, s in aws_subnet.iac_exercise_private : s.id]
  security_group_ids  = [aws_security_group.iac_exercise_endpoints[0].id]

  tags = merge(var.tags, { Name = "${var.project}-vpce-${replace(each.value, "com.amazonaws.${var.region}.", "")}" })
}
