# EKS cluster deployment using the centralized module
module "eks" {
  source = "./modules/eks"

  # Cluster Configuration
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  # VPC Discovery Configuration
  vpc_name = var.vpc_name
  vpc_tags = var.vpc_tags
  vpc_id   = var.vpc_id

  # Subnet Discovery Configuration  
  subnet_tags = var.subnet_tags
  subnet_ids  = var.subnet_ids

  # Node Group Configuration
  node_group_instance_types = var.node_group_instance_types
  node_group_desired_size   = var.node_group_desired_size
  node_group_max_size       = var.node_group_max_size
  node_group_min_size       = var.node_group_min_size
  node_group_capacity_type  = var.node_group_capacity_type
  node_group_ami_type       = var.node_group_ami_type
  node_group_disk_size      = var.node_group_disk_size

  # Security Configuration
  endpoint_private_access  = var.endpoint_private_access
  endpoint_public_access   = var.endpoint_public_access
  public_access_cidrs      = var.public_access_cidrs
  enable_cluster_log_types = var.enable_cluster_log_types

  # SSH Access Configuration
  enable_ssh_access = var.enable_ssh_access
  ssh_access_cidrs  = var.ssh_access_cidrs
  ssh_key_name      = var.ssh_key_name

  # IRSA and Add-on Configuration
  enable_irsa                     = var.enable_irsa
  enable_addon_version_management = var.enable_addon_version_management

  # ExternalDNS Configuration
  external_dns_zone_ids       = var.external_dns_zone_ids
  external_dns_domain_filters = var.external_dns_domain_filters
  external_dns_txt_owner_id   = var.external_dns_txt_owner_id
  external_dns_policy         = var.external_dns_policy

  # Tags
  tags = var.tags
}

# Outputs
output "cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks.cluster_id
}

output "cluster_arn" {
  description = "EKS cluster ARN"
  value       = module.eks.cluster_arn
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the cluster control plane"
  value       = module.eks.cluster_security_group_id
}

output "cluster_primary_security_group_id" {
  description = "Cluster security group that was created by Amazon EKS for the cluster"
  value       = module.eks.cluster_primary_security_group_id
}

output "cluster_version" {
  description = "The Kubernetes version for the cluster"
  value       = module.eks.cluster_version
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks.cluster_certificate_authority_data
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster for the OpenID Connect identity provider"
  value       = module.eks.cluster_oidc_issuer_url
}

output "node_security_group_id" {
  description = "ID of the node shared security group"
  value       = module.eks.node_security_group_id
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider if IRSA is enabled"
  value       = module.eks.oidc_provider_arn
}

output "ebs_csi_driver_role_arn" {
  description = "ARN of the EBS CSI driver IAM role"
  value       = module.eks.ebs_csi_driver_role_arn
}

output "vpc_cni_role_arn" {
  description = "ARN of the VPC CNI IAM role"
  value       = module.eks.vpc_cni_role_arn
}

output "external_dns_role_arn" {
  description = "ARN of the ExternalDNS IAM role"
  value       = module.eks.external_dns_role_arn
}

output "alb_controller_role_arn" {
  description = "ARN of the AWS Load Balancer Controller IAM role"
  value       = module.eks.alb_controller_role_arn
}

output "vpc_id" {
  description = "VPC ID used by the EKS cluster"
  value       = module.eks.vpc_id
}

output "configure_kubectl" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${data.aws_region.current.name} --name ${module.eks.cluster_name}"
}

# Data source to get current region
data "aws_region" "current" {}
