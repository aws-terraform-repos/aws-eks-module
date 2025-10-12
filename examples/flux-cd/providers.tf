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