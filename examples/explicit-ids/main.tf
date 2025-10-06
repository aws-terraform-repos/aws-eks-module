# Explicit IDs Example
# This example shows how to deploy an EKS cluster using explicit VPC and subnet IDs

module "eks" {
  source = "../../"

  cluster_name = "explicit-ids-eks-cluster"

  # Use explicit resource IDs
  vpc_id = "vpc-12345678" # Replace with your VPC ID
  subnet_ids = [          # Replace with your subnet IDs
    "subnet-12345678",
    "subnet-87654321",
    "subnet-11111111"
  ]

  # Custom cluster configuration
  cluster_version         = "1.32"
  endpoint_private_access = true
  endpoint_public_access  = false # Private cluster
  public_access_cidrs     = ["10.0.0.0/8"]

  # Custom node group configuration
  node_group_instance_types = ["m5.xlarge", "m5a.xlarge"]
  node_group_capacity_type  = "SPOT"
  node_group_desired_size   = 6
  node_group_min_size       = 3
  node_group_max_size       = 12

  # Advanced configurations
  enable_irsa = true

  tags = {
    Environment = "production"
    Project     = "microservices"
    ManagedBy   = "terraform"
  }
}

# Outputs for integration
output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_ca_certificate" {
  value = module.eks.cluster_certificate_authority_data
}

output "oidc_issuer_url" {
  value = module.eks.cluster_oidc_issuer_url
}

output "kubectl_command" {
  value = "aws eks update-kubeconfig --region ${data.aws_region.current.name} --name ${module.eks.cluster_name}"
}

data "aws_region" "current" {}
