# Flux CD Enabled EKS Cluster Example

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

  # Node Group Configuration - Using new-style node_groups map
  node_groups = {
    primary = {
      desired_size   = var.node_group_desired_size
      max_size       = var.node_group_max_size
      min_size       = var.node_group_min_size
      instance_types = var.node_group_instance_types
      capacity_type  = "ON_DEMAND"
      labels = {
        Environment = "development"
        Project     = "flux-cd-example"
      }
      tags = {
        "kubernetes.io/cluster/${var.cluster_name}" = "owned"
      }
    }
  }
  
  # Node Group Options
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

  # External DNS and Load Balancer Configuration - ENABLED for GitOps
  enable_load_balancer_controller = true
  enable_external_dns             = true
  external_dns_source             = ["ingress", "service"]
  external_dns_provider           = "aws"
  external_dns_log_level          = "info"

  # Helm Deployments Configuration - Use variable
  enable_helm_deployments = var.enable_helm_deployments

  # Flux CD Configuration - Complete GitOps setup
  enable_flux_cd                = var.enable_flux_cd
  flux_cd_git_repository_url    = var.flux_cd_git_repository_url
  flux_cd_git_repository_branch = var.flux_cd_git_repository_branch
  flux_cd_git_repository_path   = var.flux_cd_git_repository_path
  flux_cd_git_auth_secret_name  = var.flux_cd_git_auth_secret_name
  flux_cd_image_automation      = var.flux_cd_image_automation

  tags = var.tags
}
