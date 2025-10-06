# Elastic IP per NAT (one NAT per AZ for HA)
resource "aws_eip" "iac_exercise_nat" {
  for_each = aws_subnet.iac_exercise_public
  domain   = "vpc"
  tags     = merge(var.tags, { Name = "${var.project}-eip-nat-${each.key}" })
}

resource "aws_nat_gateway" "iac_exercise_ngw" {
  for_each          = aws_subnet.iac_exercise_public
  allocation_id     = aws_eip.iac_exercise_nat[each.key].id
  subnet_id         = aws_subnet.iac_exercise_public[each.key].id
  connectivity_type = "public"

  tags = merge(var.tags, { Name = "${var.project}-nat-${each.key}" })

  depends_on = [aws_internet_gateway.iac_exercise_igw]
}
