# Test valid VPC configuration
run "valid_vpc_configuration" {
  command = plan

  variables {
    organization   = "test-org"
    cluster_name   = "test-cluster"
    environment    = "test"
    aws_region     = "us-west-2"
    vpc_cidr_block = "10.100.0.0/16"
    availability_zones = [
      "us-west-2a",
      "us-west-2b",
      "us-west-2c"
    ]
    enable_azs = [true, true, true]
    public_subnet_cidrs = [
      "10.100.0.0/20",
      "10.100.16.0/20",
      "10.100.32.0/20"
    ]
    private_subnet_cidrs = [
      "10.100.48.0/20",
      "10.100.64.0/20",
      "10.100.80.0/20"
    ]
    enable_nat_gateway = true
  }

  assert {
    condition     = aws_vpc.main.cidr_block == "10.100.0.0/16"
    error_message = "VPC CIDR block should match input"
  }

  assert {
    condition     = length(aws_subnet.public) == 3
    error_message = "Should create 3 public subnets"
  }

  assert {
    condition     = length(aws_subnet.private) == 3
    error_message = "Should create 3 private subnets"
  }
}

# Test route table outputs
run "route_table_outputs" {
  command = plan

  variables {
    organization   = "test-org"
    cluster_name   = "test-cluster"
    environment    = "test"
    aws_region     = "us-west-2"
    vpc_cidr_block = "10.100.0.0/16"
    availability_zones = [
      "us-west-2a",
      "us-west-2b",
      "us-west-2c"
    ]
    enable_azs = [true, true, true]
    public_subnet_cidrs = [
      "10.100.0.0/20",
      "10.100.16.0/20",
      "10.100.32.0/20"
    ]
    private_subnet_cidrs = [
      "10.100.48.0/20",
      "10.100.64.0/20",
      "10.100.80.0/20"
    ]
    enable_nat_gateway = true
  }

  assert {
    condition     = output.public_route_table_id != ""
    error_message = "Public route table ID output should not be empty"
  }

  assert {
    condition     = length(output.private_route_table_ids) == 3
    error_message = "Should output 3 private route table IDs"
  }

  assert {
    condition     = output.private_route_table_ids[0] == aws_route_table.private["0"].id
    error_message = "First private route table ID should match resource"
  }

  assert {
    condition     = output.private_route_table_ids[1] == aws_route_table.private["1"].id
    error_message = "Second private route table ID should match resource"
  }

  assert {
    condition     = output.private_route_table_ids[2] == aws_route_table.private["2"].id
    error_message = "Third private route table ID should match resource"
  }
}

# Test subnet outputs
run "subnet_outputs" {
  command = plan

  variables {
    organization   = "test-org"
    cluster_name   = "test-cluster"
    environment    = "test"
    aws_region     = "us-west-2"
    vpc_cidr_block = "10.100.0.0/16"
    availability_zones = [
      "us-west-2a",
      "us-west-2b",
      "us-west-2c"
    ]
    enable_azs = [true, true, true]
    public_subnet_cidrs = [
      "10.100.0.0/20",
      "10.100.16.0/20",
      "10.100.32.0/20"
    ]
    private_subnet_cidrs = [
      "10.100.48.0/20",
      "10.100.64.0/20",
      "10.100.80.0/20"
    ]
    enable_nat_gateway = true
  }

  assert {
    condition     = length(output.public_subnet_ids) == 3
    error_message = "Should output 3 public subnet IDs"
  }

  assert {
    condition     = length(output.private_subnet_ids) == 3
    error_message = "Should output 3 private subnet IDs"
  }

  assert {
    condition     = length(output.public_subnet_cidrs) == 3
    error_message = "Should output 3 public subnet CIDRs"
  }

  assert {
    condition     = length(output.private_subnet_cidrs) == 3
    error_message = "Should output 3 private subnet CIDRs"
  }
}

# Test NAT gateway configuration
run "nat_gateway_enabled" {
  command = plan

  variables {
    organization   = "test-org"
    cluster_name   = "test-cluster"
    environment    = "test"
    aws_region     = "us-west-2"
    vpc_cidr_block = "10.100.0.0/16"
    availability_zones = [
      "us-west-2a",
      "us-west-2b",
      "us-west-2c"
    ]
    enable_azs = [true, true, true]
    public_subnet_cidrs = [
      "10.100.0.0/20",
      "10.100.16.0/20",
      "10.100.32.0/20"
    ]
    private_subnet_cidrs = [
      "10.100.48.0/20",
      "10.100.64.0/20",
      "10.100.80.0/20"
    ]
    enable_nat_gateway = true
  }

  assert {
    condition     = length(aws_nat_gateway.main) == 3
    error_message = "Should create 3 NAT gateways when enabled"
  }

  assert {
    condition     = length(output.nat_gateway_ids) == 3
    error_message = "Should output 3 NAT gateway IDs"
  }
}
