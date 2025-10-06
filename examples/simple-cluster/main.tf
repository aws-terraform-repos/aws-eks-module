# Simple EKS cluster deployment with minimal configuration
module "eks_simple" {
  source = "../../"

  cluster_name = "simple-eks-cluster"

  # Optional: specify VPC by name if you have multiple VPCs
  # vpc_name = "my-vpc"

  # The module will automatically:
  # - Find the default VPC if no vpc_name/vpc_tags/vpc_id specified
  # - Find private subnets with kubernetes.io/role/internal-elb = "1" tag
  # - Use default node group settings (t3.medium, 2 nodes)
  # - Enable IRSA for service accounts
  # - Configure all necessary security groups and IAM roles
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
