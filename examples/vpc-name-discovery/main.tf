# VPC Name Discovery Example
# This example shows how to deploy an EKS cluster by specifying a VPC by its name tag.

module "eks_vpc_name" {
  source = "../../modules/eks"

  cluster_name = "vpc-name-eks-cluster"
  vpc_name     = "my-production-vpc" # Replace with your VPC's Name tag

  # Optional: Customize node group
  node_group_instance_types = ["t3.large"]
  node_group_desired_size   = 3
  node_group_min_size       = 2
  node_group_max_size       = 6
}

# Configure kubectl
output "kubectl_command" {
  value = "aws eks update-kubeconfig --region ${data.aws_region.current.name} --name ${module.eks.cluster_name}"
}

data "aws_region" "current" {}
