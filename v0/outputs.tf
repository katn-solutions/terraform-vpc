output "vpc_id" {
  value       = aws_vpc.main.id
  description = "ID of the VPC"
}

output "vpc_cidr_block" {
  value       = aws_vpc.main.cidr_block
  description = "CIDR block of the VPC"
}

output "internet_gateway_id" {
  value       = aws_internet_gateway.main.id
  description = "ID of the internet gateway"
}

output "public_subnet_ids" {
  value       = [for subnet in aws_subnet.public : subnet.id]
  description = "List of public subnet IDs"
}

output "private_subnet_ids" {
  value       = [for subnet in aws_subnet.private : subnet.id]
  description = "List of private subnet IDs"
}

output "public_subnet_cidrs" {
  value       = [for subnet in aws_subnet.public : subnet.cidr_block]
  description = "List of public subnet CIDR blocks"
}

output "private_subnet_cidrs" {
  value       = [for subnet in aws_subnet.private : subnet.cidr_block]
  description = "List of private subnet CIDR blocks"
}

output "vpn_subnet_ids" {
  value       = var.enable_vpn ? [for subnet in aws_subnet.vpn : subnet.id] : []
  description = "List of VPN subnet IDs (if enabled)"
}

output "nat_gateway_ids" {
  value       = var.enable_nat_gateway ? [for nat in aws_nat_gateway.main : nat.id] : []
  description = "List of NAT gateway IDs (if enabled)"
}

output "nat_eip_public_ips" {
  value       = var.enable_nat_gateway ? [for eip in aws_eip.nat : eip.public_ip] : []
  description = "List of NAT gateway Elastic IP addresses (if enabled)"
}

output "public_route_table_id" {
  value       = aws_route_table.public.id
  description = "ID of the public route table"
}

output "private_route_table_ids" {
  value       = [for rt in aws_route_table.private : rt.id]
  description = "List of private route table IDs"
}

output "s3_endpoint_id" {
  value       = var.enable_s3_endpoint ? aws_vpc_endpoint.s3[0].id : null
  description = "ID of the S3 VPC endpoint (if enabled)"
}

output "dhcp_options_id" {
  value       = var.enable_dhcp_options ? aws_vpc_dhcp_options.main[0].id : null
  description = "ID of the DHCP options set (if enabled)"
}

output "public_subnets_by_az" {
  value = {
    for k, subnet in aws_subnet.public : k => {
      id                = subnet.id
      cidr_block        = subnet.cidr_block
      availability_zone = subnet.availability_zone
    }
  }
  description = "Map of public subnets indexed by AZ number"
}

output "private_subnets_by_az" {
  value = {
    for k, subnet in aws_subnet.private : k => {
      id                = subnet.id
      cidr_block        = subnet.cidr_block
      availability_zone = subnet.availability_zone
    }
  }
  description = "Map of private subnets indexed by AZ number"
}
