# On-Demand EKS Cluster Example

module "eks" {
  source = "../../modules/eks"

  # Basic cluster configuration
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  # VPC Discovery Configuration
  vpc_name    = var.vpc_name
  vpc_tags    = var.vpc_tags
  vpc_id      = var.vpc_id
  subnet_tags = var.subnet_tags
  subnet_ids  = var.subnet_ids

  # Node Groups Configuration - Using the proper node_groups variable
  node_groups = {
    main = {
      instance_types = ["t3.medium", "t3a.medium"]
      desired_size   = 3
      max_size       = 4
      min_size       = 1
      capacity_type  = "ON_DEMAND"
      labels         = {}
      taints         = []
      tags           = {}
    }
  }
  node_group_ami_type  = "AL2023_x86_64_STANDARD"
  node_group_disk_size = 20

  # Security Configuration
  endpoint_private_access = true
  endpoint_public_access  = true
  public_access_cidrs     = var.public_access_cidrs

  # IRSA Configuration
  enable_irsa = true

  # DNS Configuration
  create_hosted_zones    = var.create_hosted_zones
  hosted_zone_domains    = var.hosted_zone_domains
  create_subdomain_zones = var.create_subdomain_zones
  subdomain_zones        = var.subdomain_zones

  # Load Balancer and DNS Configuration
  enable_load_balancer_controller = var.enable_load_balancer_controller
  enable_external_dns             = var.enable_external_dns
  external_dns_source             = var.external_dns_source
  external_dns_provider           = var.external_dns_provider
  external_dns_log_level          = var.external_dns_log_level

  # Helm Deployment Configuration
  enable_helm_deployments = var.enable_helm_deployments
  helm_timeout            = var.helm_timeout
  wait_for_ready          = var.wait_for_ready

  # Fluent Bit Configuration
  enable_fluent_bit             = true
  fluent_bit_log_group_name     = "/aws/eks/${var.cluster_name}/applications"
  fluent_bit_log_retention_days = 30

  tags = var.tags
}
