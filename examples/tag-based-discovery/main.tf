# Tag-Based Discovery Example
# This example shows how to discover VPC and subnets using custom tags

module "eks" {
  source = "../../"

  cluster_name = "tag-based-eks-cluster"

  # Discover VPC using custom tags
  vpc_tags = {
    Environment = "production"
    Team        = "platform"
  }

  # Discover subnets using custom tags
  subnet_tags = {
    Environment = "production"
    Type        = "private"
    Kubernetes  = "allowed"
  }

  # Custom configuration
  cluster_version           = "1.32"
  node_group_instance_types = ["m5.large"]
  node_group_desired_size   = 4
  node_group_min_size       = 2
  node_group_max_size       = 8

  # Enhanced logging
  enable_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

# Additional outputs for monitoring
output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  value = module.eks.cluster_security_group_id
}

output "kubectl_command" {
  value = "aws eks update-kubeconfig --region ${data.aws_region.current.name} --name ${module.eks.cluster_name}"
}

data "aws_region" "current" {}
