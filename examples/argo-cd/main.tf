# Argo CD Enabled EKS Cluster (on-demand nodes)

module "eks" {
  source = "../../modules/eks"

  # Basic cluster configuration
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  # VPC discovery / selection
  vpc_name    = var.vpc_name
  vpc_tags    = var.vpc_tags
  vpc_id      = var.vpc_id
  subnet_tags = var.subnet_tags
  subnet_ids  = var.subnet_ids

  # Node group configuration (on-demand)
  node_groups = {
    main = {
      instance_types = var.node_group_instance_types
      desired_size   = var.node_group_desired_size
      max_size       = var.node_group_max_size
      min_size       = var.node_group_min_size
      capacity_type  = "ON_DEMAND"
      labels = {
        Environment = "production"
        Project     = "argo-cd-example"
      }
      tags = {
        "kubernetes.io/cluster/${var.cluster_name}" = "owned"
      }
    }
  }
  node_group_ami_type  = var.node_group_ami_type
  node_group_disk_size = var.node_group_disk_size

  # Security configuration
  endpoint_private_access = true
  endpoint_public_access  = true
  public_access_cidrs     = var.public_access_cidrs

  # IRSA configuration
  enable_irsa = true

  # DNS configuration
  create_hosted_zones    = var.create_hosted_zones
  hosted_zone_domains    = var.hosted_zone_domains
  create_subdomain_zones = var.create_subdomain_zones
  subdomain_zones        = var.subdomain_zones

  # External DNS and Load Balancer configuration
  enable_load_balancer_controller = var.enable_load_balancer_controller
  enable_external_dns             = var.enable_external_dns
  external_dns_source             = var.external_dns_source
  external_dns_provider           = var.external_dns_provider
  external_dns_log_level          = var.external_dns_log_level

  # Helm Deployments Configuration
  enable_helm_deployments = var.enable_helm_deployments
  helm_timeout            = var.helm_timeout
  wait_for_ready          = var.wait_for_ready

  # Argo CD Configuration
  enable_argo_cd        = var.enable_argo_cd
  argo_cd_chart_version = var.argo_cd_chart_version
  argo_cd_namespace     = var.argo_cd_namespace
  argo_cd_values        = var.argo_cd_values

  tags = var.tags
}
