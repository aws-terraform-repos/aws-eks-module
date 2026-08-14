# Advanced EKS Cluster Example — mixed on-demand/spot node groups, IRSA,
# Load Balancer Controller, ExternalDNS, and Fluent Bit logging.

module "eks" {
  source = "../../modules/eks"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_name    = var.vpc_name
  vpc_tags    = var.vpc_tags
  vpc_id      = var.vpc_id
  subnet_tags = var.subnet_tags
  subnet_ids  = var.subnet_ids

  node_groups = {
    on_demand = {
      instance_types = ["t3.medium", "t3a.medium"]
      desired_size   = 2
      max_size       = 4
      min_size       = 1
      capacity_type  = "ON_DEMAND"
      labels         = { workload = "core" }
      taints         = []
      tags           = {}
    }
    spot = {
      instance_types = ["t3.large", "t3a.large", "t3.xlarge"]
      desired_size   = 2
      max_size       = 6
      min_size       = 0
      capacity_type  = "SPOT"
      labels         = { workload = "batch" }
      taints         = []
      tags           = {}
    }
  }
  node_group_ami_type  = "AL2023_x86_64_STANDARD"
  node_group_disk_size = 30

  endpoint_private_access = true
  endpoint_public_access  = true
  public_access_cidrs     = var.public_access_cidrs

  enable_irsa = true

  enable_load_balancer_controller = true
  enable_external_dns             = var.create_hosted_zones
  external_dns_source             = ["ingress", "service"]
  external_dns_provider           = "aws"

  create_hosted_zones = var.create_hosted_zones
  hosted_zone_domains = var.hosted_zone_domains

  enable_helm_deployments = true
  helm_timeout            = 600
  wait_for_ready          = true

  enable_fluent_bit             = true
  fluent_bit_log_group_name     = "/aws/eks/${var.cluster_name}/applications"
  fluent_bit_log_retention_days = 30

  environment = var.environment
  tags        = var.tags
}
