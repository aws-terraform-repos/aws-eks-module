# Minimal EKS Cluster Example

module "eks" {
  source = "../../modules/eks"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_name   = var.vpc_name
  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  node_groups = {
    main = {
      instance_types = ["t3.medium"]
      desired_size   = 2
      max_size       = 3
      min_size       = 1
      capacity_type  = "ON_DEMAND"
    }
  }

  endpoint_private_access = true
  endpoint_public_access  = true

  environment = var.environment
  tags        = var.tags
}
