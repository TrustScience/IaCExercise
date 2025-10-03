# PUBLIC route table (shared)
resource "aws_route_table" "iac_exercise_route_table_public" {
  vpc_id = aws_vpc.iac_exercise_vpc.id
  tags   = merge(var.tags, { Name = "${var.project}-rtb-public" })
}

resource "aws_route" "iac_exercise_public_internet" {
  route_table_id         = aws_route_table.iac_exercise_route_table_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.iac_exercise_igw.id
}

resource "aws_route_table_association" "iac_exercise_public_assoc" {
  for_each       = aws_subnet.iac_exercise_public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.iac_exercise_route_table_public.id
}

# PRIVATE route tables (one per AZ so each uses its local NAT)
resource "aws_route_table" "iac_exercise_route_table_private" {
  for_each = aws_nat_gateway.iac_exercise_ngw
  vpc_id   = aws_vpc.iac_exercise_vpc.id
  tags     = merge(var.tags, { Name = "${var.project}-rtb-private-${each.key}" })
}

resource "aws_route" "iac_exercise_private_default" {
  for_each                 = aws_nat_gateway.iac_exercise_ngw
  route_table_id           = aws_route_table.iac_exercise_route_table_private[each.key].id
  destination_cidr_block   = "0.0.0.0/0"
  nat_gateway_id           = aws_nat_gateway.iac_exercise_ngw[each.key].id
}

resource "aws_route_table_association" "iac_exercise_private_assoc" {
  for_each       = aws_subnet.iac_exercise_private
  subnet_id      = each.value.id
  # use the RTB that matches the same AZ index (key)
  route_table_id = aws_route_table.iac_exercise_route_table_private[each.key].id
}
