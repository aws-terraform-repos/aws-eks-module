# Example 1: Using VPC discovery by name and default subnet tags
module "eks_by_vpc_name" {
  source = "../"

  cluster_name    = "my-eks-cluster"
  cluster_version = "1.34"

  # Discover VPC by name tag
  vpc_name = "my-vpc"
  # Uses default subnet_tags to find subnets with kubernetes.io/role/internal-elb = "1"

  node_group_instance_types = ["t3.medium"]
  node_group_desired_size   = 2
  node_group_max_size       = 4
  node_group_min_size       = 1

  # Security configuration
  endpoint_private_access = true
  endpoint_public_access  = true
  public_access_cidrs     = ["10.0.0.0/16"] # Restrict to your network

  # Node group configuration
  node_group_capacity_type = "ON_DEMAND"
  node_group_ami_type      = "AL2_x86_64"
  node_group_disk_size     = 20

  # Enable IRSA for service accounts
  enable_irsa = true

  tags = {
    Environment = "production"
    Project     = "my-project"
  }
}

# Example 2: Using VPC discovery by tags and custom subnet tags
module "eks_by_tags" {
  source = "../"

  cluster_name    = "my-eks-cluster-2"
  cluster_version = "1.28"

  # Discover VPC by tags
  vpc_tags = {
    Environment = "production"
    Team        = "platform"
  }

  # Discover subnets by custom tags
  subnet_tags = {
    Type        = "private"
    Environment = "production"
  }

  node_group_instance_types = ["t3.medium"]
  node_group_desired_size   = 2
  node_group_max_size       = 4
  node_group_min_size       = 1

  tags = {
    Environment = "production"
    Project     = "my-project"
  }
}

# Example 3: Using explicit VPC ID and subnet IDs (backward compatibility)
module "eks_explicit" {
  source = "../"

  cluster_name    = "my-eks-cluster-3"
  cluster_version = "1.28"

  # Explicit VPC and subnet IDs
  vpc_id     = "vpc-12345678"                         # Replace with your VPC ID
  subnet_ids = ["subnet-12345678", "subnet-87654321"] # Replace with your subnet IDs

  node_group_instance_types = ["t3.medium"]
  node_group_desired_size   = 2
  node_group_max_size       = 4
  node_group_min_size       = 1

  tags = {
    Environment = "production"
    Project     = "my-project"
  }
}

# Outputs for Example 1
output "cluster_endpoint_1" {
  description = "Endpoint for EKS control plane (Example 1)"
  value       = module.eks_by_vpc_name.cluster_endpoint
}

output "cluster_name_1" {
  description = "EKS cluster name (Example 1)"
  value       = module.eks_by_vpc_name.cluster_name
}

output "oidc_provider_arn_1" {
  description = "The ARN of the OIDC Provider (Example 1)"
  value       = module.eks_by_vpc_name.oidc_provider_arn
}

# Outputs for Example 2
output "cluster_endpoint_2" {
  description = "Endpoint for EKS control plane (Example 2)"
  value       = module.eks_by_tags.cluster_endpoint
}

output "cluster_name_2" {
  description = "EKS cluster name (Example 2)"
  value       = module.eks_by_tags.cluster_name
}

# Outputs for Example 3
output "cluster_endpoint_3" {
  description = "Endpoint for EKS control plane (Example 3)"
  value       = module.eks_explicit.cluster_endpoint
}

output "cluster_name_3" {
  description = "EKS cluster name (Example 3)"
  value       = module.eks_explicit.cluster_name
}
