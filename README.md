# terraform-vpc

Terraform module for deploying AWS VPC with public/private subnets, NAT gateways, and optional VPN subnets.

## Overview

Creates a complete VPC infrastructure:
- VPC with configurable CIDR block
- Public and private subnets across multiple availability zones
- Internet Gateway for public subnet egress
- Optional NAT Gateways for private subnet egress (one per AZ)
- Optional VPN subnets
- Optional VPC endpoints (S3)
- Optional custom DHCP options
- Flexible AZ enablement

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.1.7, < 2.0.0 |
| aws | >= 5.39.0, < 7.0.0 |

## Usage

### Basic VPC (3 AZs with NAT Gateways)

```hcl
module "vpc" {
  source = "git::https://github.com/katn-solutions/terraform-vpc.git//v0?ref=v1.0.0"

  organization = "myorg"
  cluster_name = "prod-cluster"
  environment  = "prod"
  aws_region   = "us-east-1"

  vpc_cidr_block      = "10.0.0.0/16"
  availability_zones  = ["us-east-1a", "us-east-1b", "us-east-1c"]
  enable_azs          = [true, true, true]

  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]

  enable_nat_gateway = true
  enable_s3_endpoint = true
}
```

### VPC with VPN Subnets

```hcl
module "vpc" {
  source = "git::https://github.com/katn-solutions/terraform-vpc.git//v0?ref=v1.0.0"

  organization = "myorg"
  cluster_name = "prod"
  environment  = "prod"
  aws_region   = "us-east-1"

  vpc_cidr_block      = "10.200.0.0/16"
  availability_zones  = ["us-east-1a", "us-east-1b"]
  enable_azs          = [true, true]

  public_subnet_cidrs  = ["10.200.1.0/24", "10.200.2.0/24"]
  private_subnet_cidrs = ["10.200.11.0/24", "10.200.12.0/24"]

  enable_vpn        = true
  vpn_subnet_count  = 2
  vpn_subnet_cidrs  = ["10.200.100.0/24", "10.200.101.0/24"]

  enable_nat_gateway = true
}
```

### VPC with Custom DHCP Options

```hcl
module "vpc" {
  source = "git::https://github.com/katn-solutions/terraform-vpc.git//v0?ref=v1.0.0"

  organization = "myorg"
  cluster_name = "prod"
  environment  = "prod"

  vpc_cidr_block      = "10.0.0.0/16"
  availability_zones  = ["us-east-1a"]
  enable_azs          = [true]

  public_subnet_cidrs  = ["10.0.1.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24"]

  enable_dhcp_options      = true
  dhcp_domain_name         = "infosec.internal"
  dhcp_domain_name_servers = ["AmazonProvidedDNS"]

  enable_nat_gateway = false  # Cost optimization
}
```

## Inputs

### Required Variables

- `organization` - Organization name for resource naming
- `cluster_name` - Name of the cluster
- `environment` - Environment (dev/staging/prod)
- `vpc_cidr_block` - CIDR block for the VPC
- `availability_zones` - List of availability zones
- `enable_azs` - List of booleans to enable/disable each AZ
- `public_subnet_cidrs` - CIDR blocks for public subnets
- `private_subnet_cidrs` - CIDR blocks for private subnets

### Optional Variables

- `aws_region` - AWS region (default: "us-east-1")
- `enable_dns_hostnames` - Enable DNS hostnames (default: true)
- `enable_dns_support` - Enable DNS support (default: true)
- `enable_nat_gateway` - Enable NAT Gateways (default: true)
- `enable_vpn` - Enable VPN subnets (default: false)
- `vpn_subnet_count` - Number of VPN subnets (default: 0)
- `vpn_subnet_cidrs` - CIDR blocks for VPN subnets (default: [])
- `enable_dhcp_options` - Enable custom DHCP options (default: false)
- `enable_s3_endpoint` - Enable S3 VPC endpoint (default: false)
- `tags` - Additional tags for resources (default: {})

## Outputs

- `vpc_id` - ID of the VPC
- `vpc_cidr_block` - CIDR block of the VPC
- `internet_gateway_id` - ID of the internet gateway
- `public_subnet_ids` - List of public subnet IDs
- `private_subnet_ids` - List of private subnet IDs
- `vpn_subnet_ids` - List of VPN subnet IDs (if enabled)
- `nat_gateway_ids` - List of NAT gateway IDs (if enabled)
- `nat_eip_public_ips` - List of NAT gateway Elastic IPs
- `public_route_table_id` - ID of the public route table
- `private_route_table_ids` - List of private route table IDs
- `public_subnets_by_az` - Map of public subnets indexed by AZ
- `private_subnets_by_az` - Map of private subnets indexed by AZ

## Architecture

### Public Subnets
- Direct route to Internet Gateway
- One per enabled AZ
- Tagged with `visibility = "public"`

### Private Subnets
- Route to NAT Gateway (if enabled)
- One per enabled AZ
- Separate route table per AZ
- Tagged with `visibility = "private"`

### NAT Gateways
- One per enabled AZ for high availability
- Elastic IP per NAT Gateway
- Placed in public subnets

### VPN Subnets
- Optional subnets for VPN endpoints
- Configurable count and placement

## Cost Optimization

NAT Gateways incur significant costs:
- $0.045/hour per NAT Gateway
- $0.045/GB data processed

For cost optimization:
- Set `enable_nat_gateway = false` and use NAT instances instead
- Use single NAT Gateway for non-HA environments
- Consider VPC endpoints for AWS services to avoid NAT costs

## License

Copyright © 2025 KATN Solutions. All rights reserved.
