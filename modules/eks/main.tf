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

# Security group for AWS Load Balancer Controller
resource "aws_security_group" "load_balancer" {
  name        = "${var.cluster_name}-lb-sg"
  description = "Security group for AWS Load Balancer Controller"
  vpc_id      = local.vpc_id

  # Allow inbound HTTPS traffic (for ALB)
  ingress {
    description      = "HTTPS inbound"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  # Allow inbound HTTP traffic (for ALB)
  ingress {
    description      = "HTTP inbound"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  # Allow all outbound traffic (will be restricted by node security group rules)
  egress {
    description      = "All outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(var.tags, {
    Name                                        = "${var.cluster_name}-lb-sg"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
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

  # Allow inbound traffic from control plane
  ingress {
    description     = "Allow HTTPS from control plane"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.cluster.id]
  }

  ingress {
    description     = "Allow kubelet and pod communication from control plane"
    from_port       = 1025
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.cluster.id]
  }

  # Allow inbound traffic from Load Balancer
  ingress {
    description     = "Allow HTTP from Load Balancer"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.load_balancer.id]
  }

  ingress {
    description     = "Allow HTTPS from Load Balancer"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.load_balancer.id]
  }

  ingress {
    description     = "Allow health checks from Load Balancer"
    from_port       = 1025
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.load_balancer.id]
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

  # Allow all outbound traffic
  egress {
    description      = "All outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(var.tags, {
    Name                                        = "${var.cluster_name}-node-sg"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
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
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-primary-node-group"
  node_role_arn   = aws_iam_role.node_group.arn
  subnet_ids      = local.subnet_ids

  scaling_config {
    desired_size = var.node_group_desired_size
    max_size     = var.node_group_max_size
    min_size     = var.node_group_min_size
  }

  update_config {
    max_unavailable = 1
  }

  ami_type       = var.node_group_ami_type
  capacity_type  = "ON_DEMAND"
  disk_size      = var.node_group_disk_size
  instance_types = var.node_group_instance_types

  tags = merge(var.tags, {
    Name                                        = "${var.cluster_name}-primary-node-group"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
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


