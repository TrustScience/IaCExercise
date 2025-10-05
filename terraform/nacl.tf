# resource "aws_network_acl" "iac_exercise_nacl" {
#   vpc_id = aws_vpc.iac_exercise_vpc.id

#   # Allow all inbound/outbound traffic on the VPC (default expected for most setups).
#   # Previously this NACL restricted egress to a private cidr which prevented
#   # ECS tasks in private subnets from reaching ECR over HTTPS, causing i/o timeouts.
#   egress {
#     protocol   = "-1"
#     rule_no    = 100
#     action     = "allow"
#     cidr_block = "0.0.0.0/0"
#     from_port  = 0
#     to_port    = 0
#   }

#   ingress {
#     protocol   = "-1"
#     rule_no    = 100
#     action     = "allow"
#     cidr_block = "0.0.0.0/0"
#     from_port  = 0
#     to_port    = 0
#   }

#   tags = {
#     Name = "main"
#   }
# }