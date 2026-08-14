output "cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks.cluster_id
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "node_groups" {
  description = "Map of attribute maps for all EKS managed node groups created"
  value       = module.eks.node_groups
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider (enable_irsa = true)"
  value       = module.eks.oidc_provider_arn
}

output "load_balancer_controller_role_arn" {
  description = "ARN of the AWS Load Balancer Controller IAM role"
  value       = module.eks.load_balancer_controller_role_arn
}

output "hosted_zone_ids" {
  description = "Map of hosted zone names to their zone IDs"
  value       = module.eks.hosted_zone_ids
}
