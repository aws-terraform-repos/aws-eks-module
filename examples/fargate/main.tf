# Fargate EKS Cluster Example

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

  # Node Groups Configuration - pass through the node_groups variable
  node_groups = var.node_groups

  # Fargate Profiles Configuration - pass through the fargate_profiles variable
  fargate_profiles = var.fargate_profiles

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

  tags = var.tags
}
