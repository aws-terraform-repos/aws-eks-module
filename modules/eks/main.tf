# Security group for EKS cluster
resource "aws_security_group" "cluster" {
  name        = "${var.cluster_name}-cluster-sg"
  description = "Security group for EKS cluster"
  vpc_id      = local.vpc_id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.public_access_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-cluster-sg"
  })
}

# Security group for EKS nodes
resource "aws_security_group" "node_group" {
  name        = "${var.cluster_name}-node-sg"
  description = "Security group for EKS nodes"
  vpc_id      = local.vpc_id

  ingress {
    description = "Allow nodes to communicate with each other"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    self        = true
  }

  ingress {
    description     = "Allow pods to communicate with the cluster API Server"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.cluster.id]
  }

  ingress {
    description     = "Allow kubelets and pods to receive communication from the cluster control plane"
    from_port       = 1025
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.cluster.id]
  }

  # Allow SSH access (optional, only if needed for debugging)
  dynamic "ingress" {
    for_each = var.enable_ssh_access ? [1] : []
    content {
      description = "SSH access"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.ssh_access_cidrs
    }
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-node-sg"
  })
}

# Security group rule to allow cluster to communicate with nodes
resource "aws_security_group_rule" "cluster_ingress_node_https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.cluster.id
  source_security_group_id = aws_security_group.node_group.id
  to_port                  = 443
  type                     = "ingress"
}

# EKS Cluster
resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = aws_iam_role.cluster.arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids              = local.subnet_ids
    security_group_ids      = [aws_security_group.cluster.id]
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.public_access_cidrs
  }

  enabled_cluster_log_types = var.enable_cluster_log_types

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSVPCResourceController,
  ]

  tags = merge(var.tags, {
    Name = var.cluster_name
  })
}

# EKS Node Groups (dynamic for multiple node groups)
resource "aws_eks_node_group" "this" {
  for_each = var.node_groups

  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-${each.key}-node-group"
  node_role_arn   = aws_iam_role.node_group.arn
  subnet_ids      = local.subnet_ids

  scaling_config {
    desired_size = each.value.desired_size
    max_size     = each.value.max_size
    min_size     = each.value.min_size
  }

  update_config {
    max_unavailable = 1
  }

  dynamic "remote_access" {
    for_each = var.enable_ssh_access ? [1] : []
    content {
      ec2_ssh_key               = var.ssh_key_name
      source_security_group_ids = [aws_security_group.node_group.id]
    }
  }

  ami_type       = var.node_group_ami_type
  capacity_type  = each.value.capacity_type
  disk_size      = var.node_group_disk_size
  instance_types = each.value.instance_types

  labels = each.value.labels

  dynamic "taint" {
    for_each = each.value.taints
    content {
      key    = taint.value.key
      value  = taint.value.value
      effect = taint.value.effect
    }
  }

  tags = merge(var.tags, each.value.tags, {
    Name = "${var.cluster_name}-${each.key}-node-group"
  })

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Also ensure cluster is ready before creating node groups.
  depends_on = [
    aws_eks_cluster.this,
    aws_iam_role_policy_attachment.node_group_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_group_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_group_AmazonEC2ContainerRegistryReadOnly
  ]
}

# EKS Fargate Profiles (dynamic for multiple profiles)
resource "aws_eks_fargate_profile" "this" {
  for_each = var.fargate_profiles

  cluster_name           = aws_eks_cluster.this.name
  fargate_profile_name   = "${var.cluster_name}-${each.key}-profile"
  pod_execution_role_arn = aws_iam_role.fargate_profile.arn
  subnet_ids             = each.value.subnet_ids != null ? each.value.subnet_ids : local.subnet_ids

  dynamic "selector" {
    for_each = each.value.selectors
    content {
      namespace = selector.value.namespace
      labels    = selector.value.labels
    }
  }

  tags = merge(var.tags, each.value.tags, {
    Name = "${var.cluster_name}-${each.key}-fargate-profile"
  })

  depends_on = [
    aws_eks_cluster.this,
    aws_iam_role_policy_attachment.fargate_profile_AmazonEKSFargatePodExecutionRolePolicy
  ]
}



# EKS Add-ons
resource "aws_eks_addon" "vpc_cni" {
  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = "vpc-cni"
  addon_version               = var.enable_addon_version_management ? data.aws_eks_addon_version.vpc_cni[0].version : null
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  service_account_role_arn    = var.enable_irsa ? aws_iam_role.vpc_cni[0].arn : null

  depends_on = [aws_eks_node_group.this, aws_eks_fargate_profile.this]

  tags = var.tags

  lifecycle {
    ignore_changes = [
      addon_version,
      service_account_role_arn
    ]
  }
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = "kube-proxy"
  addon_version               = var.enable_addon_version_management ? data.aws_eks_addon_version.kube_proxy[0].version : null
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [aws_eks_node_group.this, aws_eks_fargate_profile.this]

  tags = var.tags

  lifecycle {
    ignore_changes = [
      addon_version
    ]
  }
}

resource "aws_eks_addon" "coredns" {
  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = "coredns"
  addon_version               = var.enable_addon_version_management ? data.aws_eks_addon_version.coredns[0].version : null
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [aws_eks_node_group.this, aws_eks_fargate_profile.this]

  tags = var.tags

  lifecycle {
    ignore_changes = [
      addon_version
    ]
  }
}

resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = "aws-ebs-csi-driver"
  addon_version               = var.enable_addon_version_management ? data.aws_eks_addon_version.ebs_csi_driver[0].version : null
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  service_account_role_arn    = var.enable_irsa ? aws_iam_role.ebs_csi_driver[0].arn : null
  depends_on = [
    aws_iam_role.ebs_csi_driver,
    aws_eks_node_group.this,
    aws_eks_fargate_profile.this
  ]
  lifecycle {
    ignore_changes = [
      addon_version,
      service_account_role_arn
    ]
  }
}

resource "aws_eks_addon" "pod_identity_agent" {
  count                       = local.pod_identity_enabled ? 1 : 0
  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = "amazon-eks-pod-identity-agent"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [aws_eks_node_group.this, aws_eks_fargate_profile.this]

  tags = var.tags

  lifecycle {
    ignore_changes = [
      addon_version
    ]
  }
}
