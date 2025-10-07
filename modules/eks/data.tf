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
}
