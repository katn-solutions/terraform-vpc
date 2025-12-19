# Local variables
locals {
  vpc_name = "${var.organization}-vpc-${var.cluster_name}-${var.environment}"

  common_tags = merge(
    {
      Organization = var.organization
      Cluster      = var.cluster_name
      Environment  = var.environment
      Service      = "vpc"
    },
    var.tags
  )

  # Calculate number of enabled AZs
  enabled_azs = [
    for i, az in var.availability_zones : az
    if try(var.enable_azs[i], false)
  ]

  # Create subnet maps for enabled AZs
  public_subnets = {
    for i, az in local.enabled_azs : i => {
      az         = az
      cidr_block = var.public_subnet_cidrs[i]
    }
  }

  private_subnets = {
    for i, az in local.enabled_azs : i => {
      az         = az
      cidr_block = var.private_subnet_cidrs[i]
    }
  }

  vpn_subnets = var.enable_vpn ? {
    for i in range(var.vpn_subnet_count) : i => {
      az         = var.availability_zones[i % length(var.availability_zones)]
      cidr_block = var.vpn_subnet_cidrs[i]
    }
  } : {}
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = merge(local.common_tags, {
    Name = local.vpc_name
  })
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${local.vpc_name}-igw"
  })
}

# Elastic IPs for NAT Gateways
resource "aws_eip" "nat" {
  for_each = var.enable_nat_gateway ? local.public_subnets : {}
  domain   = "vpc"

  tags = merge(local.common_tags, {
    Name = "${local.vpc_name}-nat-eip-${each.key}"
  })
}

# NAT Gateways
resource "aws_nat_gateway" "main" {
  for_each      = var.enable_nat_gateway ? local.public_subnets : {}
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public[each.key].id

  tags = merge(local.common_tags, {
    Name = "${local.vpc_name}-nat-${each.key}"
  })

  depends_on = [aws_internet_gateway.main]
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${local.vpc_name}-public-rt"
  })
}

# Public Route to Internet Gateway
resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# Private Route Tables (one per AZ)
resource "aws_route_table" "private" {
  for_each = local.private_subnets
  vpc_id   = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${local.vpc_name}-private-rt-${each.key}"
  })
}

# Private Routes to NAT Gateway
resource "aws_route" "private_nat" {
  for_each               = var.enable_nat_gateway ? local.private_subnets : {}
  route_table_id         = aws_route_table.private[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[each.key].id
}

# Public Subnets
resource "aws_subnet" "public" {
  for_each          = local.public_subnets
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.az

  tags = merge(local.common_tags, {
    Name       = "${local.vpc_name}-public-${each.key}"
    visibility = "public"
  })
}

# Private Subnets
resource "aws_subnet" "private" {
  for_each          = local.private_subnets
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.az

  tags = merge(local.common_tags, {
    Name       = "${local.vpc_name}-private-${each.key}"
    visibility = "private"
  })
}

# VPN Subnets (optional)
resource "aws_subnet" "vpn" {
  for_each          = local.vpn_subnets
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.az

  tags = merge(local.common_tags, {
    Name = "${local.vpc_name}-vpn-${each.key}"
  })
}

# Public Subnet Route Table Associations
resource "aws_route_table_association" "public" {
  for_each       = local.public_subnets
  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public.id
}

# Private Subnet Route Table Associations
resource "aws_route_table_association" "private" {
  for_each       = local.private_subnets
  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private[each.key].id
}

# VPC DHCP Options
resource "aws_vpc_dhcp_options" "main" {
  count               = var.enable_dhcp_options ? 1 : 0
  domain_name         = var.dhcp_domain_name
  domain_name_servers = var.dhcp_domain_name_servers

  tags = merge(local.common_tags, {
    Name = "${local.vpc_name}-dhcp-options"
  })
}

# VPC DHCP Options Association
resource "aws_vpc_dhcp_options_association" "main" {
  count           = var.enable_dhcp_options ? 1 : 0
  vpc_id          = aws_vpc.main.id
  dhcp_options_id = aws_vpc_dhcp_options.main[0].id
}

# VPC Endpoints
resource "aws_vpc_endpoint" "s3" {
  count        = var.enable_s3_endpoint ? 1 : 0
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${var.aws_region}.s3"

  tags = merge(local.common_tags, {
    Name = "${local.vpc_name}-s3-endpoint"
  })
}

# S3 Endpoint Route Table Associations
resource "aws_vpc_endpoint_route_table_association" "s3_private" {
  for_each        = var.enable_s3_endpoint ? local.private_subnets : {}
  route_table_id  = aws_route_table.private[each.key].id
  vpc_endpoint_id = aws_vpc_endpoint.s3[0].id
}
