# Root-level main.tf - Example usage of the centralized EKS module
# This file demonstrates how to use the centralized EKS module from the modules/eks directory

module "eks_cluster" {
  source = "./modules/eks"

  cluster_name = "example-eks-cluster"

  # VPC Configuration - choose one approach:
  # 1. Discover VPC by name tag
  vpc_name = "my-vpc"

  # 2. Or discover VPC by custom tags
  # vpc_tags = {
  #   Environment = "dev"
  #   Project     = "my-project"
  # }

  # 3. Or specify explicit VPC ID
  # vpc_id = "vpc-12345678"

  # Subnet Configuration - choose one approach:
  # 1. Discover subnets by tags (default: kubernetes.io/role/internal-elb)
  subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }

  # 2. Or specify explicit subnet IDs
  # subnet_ids = ["subnet-12345678", "subnet-87654321"]

  # Node Group Configuration
  node_group_instance_types = ["t3.medium"]
  node_group_desired_size   = 2
  node_group_max_size       = 4
  node_group_min_size       = 1

  # Security Configuration
  public_access_cidrs = ["0.0.0.0/0"] # Restrict this to your IP for security
  enable_ssh_access   = false         # Enable only if needed for debugging

  # Feature Configuration
  enable_irsa                     = true
  enable_addon_version_management = true
  enable_cluster_log_types        = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  # Tags
  tags = {
    Environment = "development"
    Project     = "aws-eks-module"
    Terraform   = "true"
  }
}

# Outputs
output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks_cluster.cluster_endpoint
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks_cluster.cluster_name
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.eks_cluster.cluster_security_group_id
}

output "node_groups_iam_role_arn" {
  description = "IAM role ARN for EKS node groups"
  value       = module.eks_cluster.node_groups_iam_role_arn
}

output "oidc_provider_arn" {
  description = "ARN of the OIDC Provider for IRSA"
  value       = module.eks_cluster.oidc_provider_arn
}

output "configure_kubectl" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${data.aws_region.current.name} --name ${module.eks_cluster.cluster_name}"
}

# Data source for current region
data "aws_region" "current" {}

