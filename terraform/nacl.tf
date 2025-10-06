# data "aws_prefix_list" "ecr" {
#   name = "com.amazonaws.${var.region}.ecr"
# }

# resource "aws_network_acl" "main" {
#   vpc_id = aws_vpc.iac_exercise_vpc.id

#   egress {
#     protocol   = "tcp"
#     rule_no    = 200
#     action     = "allow"
#     cidr_block = var.vpc_cidr
#     from_port  = 443
#     to_port    = 443
#   }

#   ingress {
#     protocol   = "tcp"
#     rule_no    = 100
#     action     = "allow"
#     cidr_block = var.vpc_cidr
#     from_port  = 80
#     to_port    = 80
#   }

#   tags = {
#     Name = "main"
#   }
# }

# resource "aws_network_acl_rule" "iac_exercise_ecr_outbound_nacl" {
#   network_acl_id = aws_network_acl.main.id
#   rule_number    = 100
#   egress         = true
#   protocol       = "tcp"
#   rule_action    = "allow"
#   from_port      = 443
#   to_port        = 443
#   cidr_block     = data.aws_prefix_list.ecr.cidr_blocks
# }

# resource "aws_network_acl_rule" "ecr_inbound_nacl" {
#   network_acl_id = aws_network_acl.main.id
#   rule_number    = 101
#   egress         = false
#   protocol       = "tcp"
#   rule_action    = "allow"
#   from_port      = 1024 # Ephemeral port range for return traffic
#   to_port        = 65535 # Ephemeral port range for return traffic
#   cidr_block     = data.aws_prefix_list.ecr.cidr_blocks
# }

