# Simple EKS cluster deployment with minimal configuration
module "eks_simple" {
  source = "./modules/eks"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  
  # VPC Discovery
  vpc_id = var.vpc_id
  
  # Node Group Configuration
  node_group_instance_types = var.node_group_instance_types
  node_group_desired_size   = var.node_group_desired_size
  node_group_max_size       = var.node_group_max_size
  node_group_min_size       = var.node_group_min_size
  node_group_capacity_type  = var.node_group_capacity_type
  node_group_ami_type       = var.node_group_ami_type
  node_group_disk_size      = var.node_group_disk_size
  
  # Security Configuration
  endpoint_private_access = var.endpoint_private_access
  endpoint_public_access  = var.endpoint_public_access
  public_access_cidrs     = var.public_access_cidrs
  
  # IRSA
  enable_irsa = var.enable_irsa
  
  # Tags
  tags = var.tags
}

# Outputs
output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks_simple.cluster_endpoint
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks_simple.cluster_name
}

output "configure_kubectl" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region us-east-1 --name ${module.eks_simple.cluster_name}"
}
