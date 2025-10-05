output "vpc_id" {
  value       = aws_vpc.iac_exercise_vpc.id
  description = "VPC ID"
}

output "public_subnet_ids" {
  value       = [for k, s in aws_subnet.iac_exercise_public : s.id]
  description = "Public subnet IDs (by AZ index)"
}

output "private_subnet_ids" {
  value       = [for k, s in aws_subnet.iac_exercise_private : s.id]
  description = "Private subnet IDs (by AZ index)"
}

output "public_subnet_cidrs" {
  value       = [for k, s in aws_subnet.iac_exercise_public : s.cidr_block]
  description = "Public subnet CIDRs"
}

output "private_subnet_cidrs" {
  value       = [for k, s in aws_subnet.iac_exercise_private : s.cidr_block]
  description = "Private subnet CIDRs"
}

# output "nat_gateway_ids" {
#   value       = [for k, n in aws_nat_gateway.iac_exercise_ngw : n.id]
#   description = "NAT Gateway IDs (per AZ)"
# }

output "alb_dns_name" {
  value       = aws_lb.app_alb.dns_name
  description = "Public DNS of the Application Load Balancer"
}

output "service_name" {
  value       = aws_ecs_service.app.name
  description = "ECS Service name"
}

output "cluster_name" {
  value       = aws_ecs_cluster.this.name
  description = "ECS Cluster name"
}


output "target_group_arn" {
  value       = aws_lb_target_group.app_tg.arn
  description = "ARN of the target group"
}
