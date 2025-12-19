variable "organization" {
  type        = string
  description = "Organization name for resource naming"
}

variable "cluster_name" {
  type        = string
  description = "Name of the cluster"
}

variable "environment" {
  type        = string
  description = "Environment (dev/staging/prod)"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones"
}

variable "enable_azs" {
  type        = list(bool)
  description = "List of booleans to enable/disable each AZ"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for public subnets (one per AZ)"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for private subnets (one per AZ)"
}

variable "enable_dns_hostnames" {
  type        = bool
  description = "Enable DNS hostnames in the VPC"
  default     = true
}

variable "enable_dns_support" {
  type        = bool
  description = "Enable DNS support in the VPC"
  default     = true
}

variable "enable_nat_gateway" {
  type        = bool
  description = "Enable NAT Gateway for private subnets"
  default     = true
}

variable "enable_vpn" {
  type        = bool
  description = "Enable VPN subnets"
  default     = false
}

variable "vpn_subnet_count" {
  type        = number
  description = "Number of VPN subnets to create"
  default     = 0
}

variable "vpn_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for VPN subnets"
  default     = []
}

variable "enable_dhcp_options" {
  type        = bool
  description = "Enable custom DHCP options"
  default     = false
}

variable "dhcp_domain_name" {
  type        = string
  description = "DHCP domain name"
  default     = ""
}

variable "dhcp_domain_name_servers" {
  type        = list(string)
  description = "DHCP domain name servers"
  default     = ["AmazonProvidedDNS"]
}

variable "enable_s3_endpoint" {
  type        = bool
  description = "Enable VPC endpoint for S3"
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "Additional tags for resources"
  default     = {}
}
