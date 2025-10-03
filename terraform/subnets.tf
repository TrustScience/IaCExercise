locals {
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)

  # Derive subnet CIDRs deterministically from VPC CIDR
  # first N for public, next N for private
  public_subnet_cidrs  = [for i in range(var.az_count) : cidrsubnet(var.vpc_cidr, 4, i)]
  private_subnet_cidrs = [for i in range(var.az_count) : cidrsubnet(var.vpc_cidr, 4, i + var.az_count)]
}

resource "aws_subnet" "iac_exercise_public" {
  for_each = { for idx, az in local.azs : idx => { az = az, cidr = local.public_subnet_cidrs[idx] } }

  vpc_id                  = aws_vpc.iac_exercise_vpc.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name                       = "${var.project}-public-${each.key}"
    "kubernetes.io/role/elb"   = "1"            # if you ever use EKS
    Project                    = var.project
  })
}

resource "aws_subnet" "iac_exercise_private" {
  for_each = { for idx, az in local.azs : idx => { az = az, cidr = local.private_subnet_cidrs[idx] } }

  vpc_id            = aws_vpc.iac_exercise_vpc.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(var.tags, {
    Name                            = "${var.project}-private-${each.key}"
    "kubernetes.io/role/internal-elb" = "1"     # if you ever use EKS
    Project                         = var.project
  })
}
