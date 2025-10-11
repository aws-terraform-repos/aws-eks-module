# Cluster outputs
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
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_version" {
  description = "The Kubernetes version for the cluster"
  value       = module.eks.cluster_version
}

output "cluster_security_group_id" {
  description = "Cluster security group that was created by Amazon EKS for the cluster"
  value       = module.eks.cluster_security_group_id
}

output "cluster_primary_security_group_id" {
  description = "Cluster security group that was created by Amazon EKS for the cluster. Managed node groups use this security group for control-plane-to-data-plane communication. Referred to as 'Cluster security group' in the EKS console"
  value       = module.eks.cluster_primary_security_group_id
}

output "cluster_iam_role_name" {
  description = "IAM role name associated with EKS cluster"
  value       = module.eks.cluster_iam_role_name
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN associated with EKS cluster"
  value       = module.eks.cluster_iam_role_arn
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster for the OpenID Connect identity provider"
  value       = module.eks.cluster_oidc_issuer_url
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks.cluster_certificate_authority_data
}

# Node group outputs (for system components)
output "node_groups" {
  description = "Map of attribute maps for all EKS managed node groups created"
  value       = module.eks.node_groups
}

output "node_security_group_id" {
  description = "ID of the node shared security group"
  value       = module.eks.node_security_group_id
}

output "node_groups_iam_role_name" {
  description = "IAM role name for EKS node groups"
  value       = module.eks.node_groups_iam_role_name
}

output "node_groups_iam_role_arn" {
  description = "IAM role ARN for EKS node groups"
  value       = module.eks.node_groups_iam_role_arn
}

# IRSA outputs
output "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider if `enable_irsa = true`"
  value       = module.eks.oidc_provider_arn
}

# Load Balancer Controller outputs
output "load_balancer_controller_role_arn" {
  description = "ARN of the AWS Load Balancer Controller IAM role"
  value       = module.eks.load_balancer_controller_role_arn
}

output "alb_controller_role_arn" {
  description = "ARN of the AWS Load Balancer Controller IAM role"
  value       = module.eks.alb_controller_role_arn
}

# ExternalDNS outputs
output "external_dns_role_arn" {
  description = "ARN of the ExternalDNS IAM role"
  value       = module.eks.external_dns_role_arn
}

# EBS CSI Driver outputs
output "ebs_csi_driver_role_arn" {
  description = "ARN of the EBS CSI driver IAM role"
  value       = module.eks.ebs_csi_driver_role_arn
}

# VPC CNI outputs
output "vpc_cni_role_arn" {
  description = "ARN of the VPC CNI IAM role"
  value       = module.eks.vpc_cni_role_arn
}

# VPC outputs
output "vpc_id" {
  description = "VPC ID used by the EKS cluster"
  value       = module.eks.vpc_id
}

# Route53 outputs
output "hosted_zone_ids" {
  description = "Map of domain names to hosted zone IDs"
  value       = module.eks.hosted_zone_ids
}

output "hosted_zone_name_servers" {
  description = "Map of domain names to name servers"
  value       = module.eks.hosted_zone_name_servers
}

output "external_dns_domains" {
  description = "All domains configured for external-dns"
  value       = module.eks.external_dns_domains
}

# Helm deployment outputs
output "helm_aws_load_balancer_controller_status" {
  description = "Status of the AWS Load Balancer Controller Helm release"
  value       = module.eks.helm_aws_load_balancer_controller_status
}

output "helm_external_dns_status" {
  description = "Status of the ExternalDNS Helm release"
  value       = module.eks.helm_external_dns_status
}

output "helm_deployments_enabled" {
  description = "Whether Helm deployments are enabled"
  value       = module.eks.helm_deployments_enabled
}