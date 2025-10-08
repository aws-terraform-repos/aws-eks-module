data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_partition" "current" {}

# Note: EKS managed node groups will automatically use the appropriate AMI for the cluster version
# The EKS service handles AMI selection, so we don't need to specify AMI details manually

# TLS certificate for OIDC
data "tls_certificate" "eks" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

# IAM policy documents
data "aws_iam_policy_document" "cluster_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "node_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# EKS Add-on versions
data "aws_eks_addon_version" "vpc_cni" {
  count              = var.enable_addon_version_management ? 1 : 0
  addon_name         = "vpc-cni"
  kubernetes_version = var.cluster_version
  most_recent        = true
}

data "aws_eks_addon_version" "kube_proxy" {
  count              = var.enable_addon_version_management ? 1 : 0
  addon_name         = "kube-proxy"
  kubernetes_version = var.cluster_version
  most_recent        = true
}

data "aws_eks_addon_version" "coredns" {
  count              = var.enable_addon_version_management ? 1 : 0
  addon_name         = "coredns"
  kubernetes_version = var.cluster_version
  most_recent        = true
}

data "aws_eks_addon_version" "ebs_csi_driver" {
  count              = var.enable_addon_version_management ? 1 : 0
  addon_name         = "aws-ebs-csi-driver"
  kubernetes_version = var.cluster_version
  most_recent        = true
}

# VPC data source - discover VPC by name or tags
data "aws_vpc" "selected" {
  count = var.vpc_id == null ? 1 : 0

  dynamic "filter" {
    for_each = var.vpc_name != null ? [1] : []
    content {
      name   = "tag:Name"
      values = [var.vpc_name]
    }
  }

  dynamic "filter" {
    for_each = var.vpc_tags
    content {
      name   = "tag:${filter.key}"
      values = [filter.value]
    }
  }
}

# Subnets data source - discover subnets by tags within the VPC
data "aws_subnets" "selected" {
  count = var.subnet_ids == null ? 1 : 0

  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }

  # If specific subnet tags are provided, use them
  dynamic "filter" {
    for_each = length(var.subnet_tags) > 0 ? var.subnet_tags : {}
    content {
      name   = "tag:${filter.key}"
      values = [filter.value]
    }
  }

  # If no specific tags provided, find private subnets (fallback)
  dynamic "filter" {
    for_each = length(var.subnet_tags) == 0 ? [1] : []
    content {
      name   = "tag:Name"
      values = ["*private*"]
    }
  }
}

# Fallback: get all subnets if no private subnets found
data "aws_subnets" "all_subnets" {
  count = var.subnet_ids == null && length(data.aws_subnets.selected[0].ids) == 0 ? 1 : 0

  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }
}

# Get subnet details for AZ filtering
data "aws_subnet" "selected_subnets" {
  for_each = var.subnet_ids == null ? toset(
    length(try(data.aws_subnets.selected[0].ids, [])) > 0 ?
    data.aws_subnets.selected[0].ids :
    try(data.aws_subnets.all_subnets[0].ids, [])
  ) : toset(var.subnet_ids)
  id = each.value
}

# EKS supported availability zones (excluding us-east-1e)
locals {
  eks_supported_azs = [
    "us-east-1a",
    "us-east-1b",
    "us-east-1c",
    "us-east-1d",
    "us-east-1f"
  ]
}

# Local values to handle both explicit and discovered resources
locals {
  vpc_id = var.vpc_id != null ? var.vpc_id : data.aws_vpc.selected[0].id

  # Filter subnets to only include those in EKS-supported AZs
  all_discovered_subnet_ids = var.subnet_ids != null ? var.subnet_ids : (
    length(try(data.aws_subnets.selected[0].ids, [])) > 0 ?
    data.aws_subnets.selected[0].ids :
    try(data.aws_subnets.all_subnets[0].ids, [])
  )

  # Only use subnets in EKS-supported availability zones
  subnet_ids = [
    for subnet_id in local.all_discovered_subnet_ids :
    subnet_id if contains(local.eks_supported_azs, data.aws_subnet.selected_subnets[subnet_id].availability_zone)
  ]

  # External DNS Zones Configuration
  all_zone_ids = concat(
    values(aws_route53_zone.cluster_zones)[*].zone_id,
    values(aws_route53_zone.cluster_subdomains)[*].zone_id,
    var.external_dns_zone_ids
  )

  all_domains = concat(
    var.hosted_zone_domains,
    [for subdomain in var.subdomain_zones : "${subdomain}.${var.primary_domain}"],
    var.external_dns_domain_filters
  )

  # EKS-compatible instance types (updated list as of 2024)
  eks_compatible_instance_types = {
    # General Purpose - Current Generation
    "t3.nano"    = { vcpu = 2, memory = 0.5, network = "Up to 5 Gigabit" }
    "t3.micro"   = { vcpu = 2, memory = 1, network = "Up to 5 Gigabit" }
    "t3.small"   = { vcpu = 2, memory = 2, network = "Up to 5 Gigabit" }
    "t3.medium"  = { vcpu = 2, memory = 4, network = "Up to 5 Gigabit" }
    "t3.large"   = { vcpu = 2, memory = 8, network = "Up to 5 Gigabit" }
    "t3.xlarge"  = { vcpu = 4, memory = 16, network = "Up to 5 Gigabit" }
    "t3.2xlarge" = { vcpu = 8, memory = 32, network = "Up to 5 Gigabit" }

    # T3a instances (AMD-based, typically cheaper)
    "t3a.nano"    = { vcpu = 2, memory = 0.5, network = "Up to 5 Gigabit" }
    "t3a.micro"   = { vcpu = 2, memory = 1, network = "Up to 5 Gigabit" }
    "t3a.small"   = { vcpu = 2, memory = 2, network = "Up to 5 Gigabit" }
    "t3a.medium"  = { vcpu = 2, memory = 4, network = "Up to 5 Gigabit" }
    "t3a.large"   = { vcpu = 2, memory = 8, network = "Up to 5 Gigabit" }
    "t3a.xlarge"  = { vcpu = 4, memory = 16, network = "Up to 5 Gigabit" }
    "t3a.2xlarge" = { vcpu = 8, memory = 32, network = "Up to 5 Gigabit" }

    # M5 instances (balanced compute, memory, networking)
    "m5.large"    = { vcpu = 2, memory = 8, network = "Up to 10 Gigabit" }
    "m5.xlarge"   = { vcpu = 4, memory = 16, network = "Up to 10 Gigabit" }
    "m5.2xlarge"  = { vcpu = 8, memory = 32, network = "Up to 10 Gigabit" }
    "m5.4xlarge"  = { vcpu = 16, memory = 64, network = "Up to 10 Gigabit" }
    "m5.8xlarge"  = { vcpu = 32, memory = 128, network = "10 Gigabit" }
    "m5.12xlarge" = { vcpu = 48, memory = 192, network = "12 Gigabit" }
    "m5.16xlarge" = { vcpu = 64, memory = 256, network = "20 Gigabit" }
    "m5.24xlarge" = { vcpu = 96, memory = 384, network = "25 Gigabit" }

    # M5a instances (AMD-based)
    "m5a.large"   = { vcpu = 2, memory = 8, network = "Up to 10 Gigabit" }
    "m5a.xlarge"  = { vcpu = 4, memory = 16, network = "Up to 10 Gigabit" }
    "m5a.2xlarge" = { vcpu = 8, memory = 32, network = "Up to 10 Gigabit" }
    "m5a.4xlarge" = { vcpu = 16, memory = 64, network = "Up to 10 Gigabit" }

    # M6i instances (latest generation)
    "m6i.large"   = { vcpu = 2, memory = 8, network = "Up to 12.5 Gigabit" }
    "m6i.xlarge"  = { vcpu = 4, memory = 16, network = "Up to 12.5 Gigabit" }
    "m6i.2xlarge" = { vcpu = 8, memory = 32, network = "Up to 12.5 Gigabit" }
    "m6i.4xlarge" = { vcpu = 16, memory = 64, network = "Up to 12.5 Gigabit" }

    # C5 instances (compute optimized)
    "c5.large"   = { vcpu = 2, memory = 4, network = "Up to 10 Gigabit" }
    "c5.xlarge"  = { vcpu = 4, memory = 8, network = "Up to 10 Gigabit" }
    "c5.2xlarge" = { vcpu = 8, memory = 16, network = "Up to 10 Gigabit" }
    "c5.4xlarge" = { vcpu = 16, memory = 32, network = "Up to 10 Gigabit" }

    # R5 instances (memory optimized)
    "r5.large"   = { vcpu = 2, memory = 16, network = "Up to 10 Gigabit" }
    "r5.xlarge"  = { vcpu = 4, memory = 32, network = "Up to 10 Gigabit" }
    "r5.2xlarge" = { vcpu = 8, memory = 64, network = "Up to 10 Gigabit" }
    "r5.4xlarge" = { vcpu = 16, memory = 128, network = "Up to 10 Gigabit" }
  }

  # Validate that user-provided instance types are EKS-compatible
  invalid_instance_types = [
    for instance_type in var.node_group_instance_types :
    instance_type if !contains(keys(local.eks_compatible_instance_types), instance_type)
  ]

  # Calculate average spot prices per instance type
  spot_prices_by_instance = {
    for instance_type in var.node_group_instance_types :
    instance_type => {
      # Get all prices for this instance type across AZs
      prices = [
        for key, price_data in data.aws_ec2_spot_price.current :
        tonumber(price_data.spot_price) if split("_", key)[0] == instance_type
      ]
      # Calculate average and min price
      avg_price = length([
        for key, price_data in data.aws_ec2_spot_price.current :
        tonumber(price_data.spot_price) if split("_", key)[0] == instance_type
        ]) > 0 ? sum([
        for key, price_data in data.aws_ec2_spot_price.current :
        tonumber(price_data.spot_price) if split("_", key)[0] == instance_type
        ]) / length([
        for key, price_data in data.aws_ec2_spot_price.current :
        tonumber(price_data.spot_price) if split("_", key)[0] == instance_type
      ]) : 0
      min_price = length([
        for key, price_data in data.aws_ec2_spot_price.current :
        tonumber(price_data.spot_price) if split("_", key)[0] == instance_type
        ]) > 0 ? min([
        for key, price_data in data.aws_ec2_spot_price.current :
        tonumber(price_data.spot_price) if split("_", key)[0] == instance_type
      ]...) : 0
      max_price = length([
        for key, price_data in data.aws_ec2_spot_price.current :
        tonumber(price_data.spot_price) if split("_", key)[0] == instance_type
        ]) > 0 ? max([
        for key, price_data in data.aws_ec2_spot_price.current :
        tonumber(price_data.spot_price) if split("_", key)[0] == instance_type
      ]...) : 0
      instance_specs = lookup(local.eks_compatible_instance_types, instance_type, {})
    }
  }

  # Recommend cost-effective instance types based on spot pricing
  cost_optimized_recommendations = [
    for instance_type, pricing in local.spot_prices_by_instance :
    {
      instance_type   = instance_type
      avg_hourly_cost = pricing.avg_price
      min_hourly_cost = pricing.min_price
      max_hourly_cost = pricing.max_price
      vcpu            = lookup(pricing.instance_specs, "vcpu", 0)
      memory_gb       = lookup(pricing.instance_specs, "memory", 0)
      cost_per_vcpu   = pricing.avg_price > 0 && lookup(pricing.instance_specs, "vcpu", 0) > 0 ? pricing.avg_price / lookup(pricing.instance_specs, "vcpu", 1) : 999
      cost_per_gb     = pricing.avg_price > 0 && lookup(pricing.instance_specs, "memory", 0) > 0 ? pricing.avg_price / lookup(pricing.instance_specs, "memory", 1) : 999
    }
  ]
}

# Get availability zones for the region
data "aws_availability_zones" "available" {
  state = "available"

  # Exclude problematic AZs for EKS
  exclude_names = ["us-east-1e"]
}

# Query spot prices for each instance type and AZ combination
data "aws_ec2_spot_price" "current" {
  for_each = toset([
    for combo in setproduct(var.node_group_instance_types, data.aws_availability_zones.available.names) :
    "${combo[0]}_${combo[1]}"
  ])

  instance_type     = split("_", each.key)[0]
  availability_zone = split("_", each.key)[1]

  filter {
    name   = "product-description"
    values = ["Linux/UNIX"]
  }
}
