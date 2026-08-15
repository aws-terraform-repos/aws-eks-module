# Configure the AWS Provider
provider "aws" {
  # Configuration will be taken from:
  # - Environment variables (AWS_PROFILE, AWS_REGION, etc.)
  # - AWS credentials file (~/.aws/credentials)
  # - IAM role (if running on EC2)

  default_tags {
    tags = {
      ManagedBy = "terraform"
      Module    = "aws-eks-module"
    }
  }
}

# Configure Helm Provider
provider "helm" {
  kubernetes = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}

# Configure Kubernetes Provider
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

# Configure kubectl Provider (used for Flux CD GitRepository/Kustomization manifests)
#
# lazy_load defers building the client until first use instead of validating
# host/cert at provider-configure time, since those come from module.eks
# outputs that are unknown until the cluster is created.
provider "kubectl" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  load_config_file       = false
  lazy_load              = true
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}
