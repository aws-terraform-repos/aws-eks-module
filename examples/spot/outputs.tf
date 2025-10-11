# Outputs for Spot Instance EKS example

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
  description = "The Kubernetes server version for the EKS cluster"
  value       = module.eks.cluster_version
}



output "cluster_security_group_id" {
  description = "Cluster security group that was created by Amazon EKS for the cluster"
  value       = module.eks.cluster_security_group_id
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

output "cluster_primary_security_group_id" {
  description = "Cluster security group that was created by Amazon EKS for the cluster. Managed node groups use this security group for control-plane-to-data-plane communication. Referred to as 'Cluster security group' in the EKS console"
  value       = module.eks.cluster_primary_security_group_id
}

# Node group outputs
output "node_groups" {
  description = "Map of attribute maps for all EKS managed node groups created"
  value       = module.eks.node_groups
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

# ExternalDNS outputs
output "external_dns_role_arn" {
  description = "ARN of the ExternalDNS IAM role"
  value       = module.eks.external_dns_role_arn
}

# Route53 outputs
output "hosted_zone_ids" {
  description = "Map of hosted zone names to their zone IDs"
  value       = module.eks.hosted_zone_ids
}

output "hosted_zone_name_servers" {
  description = "Map of hosted zone names to their name servers"
  value       = module.eks.hosted_zone_name_servers
}

# kubectl config command
output "kubeconfig_command" {
  description = "Command to update kubeconfig for the EKS cluster"
  value       = "aws eks update-kubeconfig --region ${data.aws_region.current.name} --name ${module.eks.cluster_name}"
}

# Spot instance specific information
output "spot_instance_info" {
  description = "Information about spot instance configuration"
  value = {
    capacity_type         = "SPOT"
    instance_types        = var.node_group_instance_types
    cost_savings          = "Up to 90% savings compared to on-demand instances"
    interruption_handling = "Automatic replacement when instances are interrupted"
  }
}

# Data source for current region
data "aws_region" "current" {}