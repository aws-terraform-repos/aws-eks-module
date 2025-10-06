data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_partition" "current" {}

# Get the latest EKS optimized AMI
data "aws_ssm_parameter" "eks_ami_release_version" {
  name = "/aws/service/eks/optimized-ami/${var.cluster_version}/amazon-linux-2/recommended/release_version"
}

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

  dynamic "filter" {
    for_each = var.subnet_tags
    content {
      name   = "tag:${filter.key}"
      values = [filter.value]
    }
  }
}

# Local values to handle both explicit and discovered resources
locals {
  vpc_id     = var.vpc_id != null ? var.vpc_id : data.aws_vpc.selected[0].id
  subnet_ids = var.subnet_ids != null ? var.subnet_ids : data.aws_subnets.selected[0].ids
}
