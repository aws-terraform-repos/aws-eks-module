# Flux CD Enabled EKS Cluster Example

module "eks" {
  source = "../../modules/eks"

  # Basic cluster configuration
  cluster_name    = "flux-cd-eks-cluster"
  cluster_version = "1.32"

  # VPC Discovery Configuration - Using name-based discovery
  vpc_name = "default" # Replace with your VPC name or use vpc_id

  # Node Group Configuration
  node_group_instance_types = ["t3.medium"]
  node_group_desired_size   = 2
  node_group_max_size       = 4
  node_group_min_size       = 1
  node_group_capacity_type  = "ON_DEMAND"
  node_group_ami_type       = "AL2023_x86_64_STANDARD"
  node_group_disk_size      = 20

  # Security Configuration
  endpoint_private_access = true
  endpoint_public_access  = true
  public_access_cidrs     = ["10.0.0.0/16"] # Update with your IP/CIDR

  # IRSA Configuration
  enable_irsa = true

  # Helm Deployments
  enable_helm_deployments = false # Set to true once cluster is created and kubectl is configured

  # Flux CD Configuration
  enable_flux_cd                = true
  flux_cd_git_repository_url    = "https://github.com/your-org/k8s-manifests" # Replace with your repository
  flux_cd_git_repository_branch = "main"
  flux_cd_git_repository_path   = "./clusters/flux-cd-eks-cluster"
  flux_cd_image_automation      = true # Enable automatic image updates
  # flux_cd_git_auth_secret_name  = "flux-git-auth"  # Uncomment for private repositories

  tags = {
    Environment = "development"
    Project     = "flux-cd-example"
    ManagedBy   = "terraform"
    Owner       = "platform-team"
  }
}
