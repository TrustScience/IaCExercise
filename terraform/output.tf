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

output "nat_gateway_ids" {
  value       = [for k, n in aws_nat_gateway.iac_exercise_ngw : n.id]
  description = "NAT Gateway IDs (per AZ)"
}
