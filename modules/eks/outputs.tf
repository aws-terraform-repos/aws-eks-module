output "cluster_id" {
  description = "EKS cluster ID"
  value       = aws_eks_cluster.this.cluster_id
}

output "cluster_arn" {
  description = "EKS cluster ARN"
  value       = aws_eks_cluster.this.arn
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane"
  value       = aws_security_group.cluster.id
}

output "cluster_iam_role_name" {
  description = "IAM role name associated with EKS cluster"
  value       = aws_iam_role.cluster.name
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN associated with EKS cluster"
  value       = aws_iam_role.cluster.arn
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

output "cluster_primary_security_group_id" {
  description = "Cluster security group that was created by Amazon EKS for the cluster"
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

output "cluster_version" {
  description = "The Kubernetes version for the cluster"
  value       = aws_eks_cluster.this.version
}

output "node_groups" {
  description = "EKS node groups"
  value       = aws_eks_node_group.this
}

output "node_security_group_id" {
  description = "ID of the node shared security group"
  value       = aws_security_group.node_group.id
}

output "node_groups_iam_role_name" {
  description = "IAM role name for EKS node groups"
  value       = aws_iam_role.node_group.name
}

output "node_groups_iam_role_arn" {
  description = "IAM role ARN for EKS node groups"
  value       = aws_iam_role.node_group.arn
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider if enabled"
  value       = var.enable_irsa ? aws_iam_openid_connect_provider.eks[0].arn : null
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster for the OpenID Connect identity provider"
  value       = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

output "ebs_csi_driver_role_arn" {
  description = "ARN of the EBS CSI driver IAM role"
  value       = var.enable_irsa ? aws_iam_role.ebs_csi_driver[0].arn : null
}

output "vpc_cni_role_arn" {
  description = "ARN of the VPC CNI IAM role"
  value       = var.enable_irsa ? aws_iam_role.vpc_cni[0].arn : null
}

output "external_dns_role_arn" {
  description = "ARN of the ExternalDNS IAM role"
  value       = var.enable_irsa ? aws_iam_role.external_dns[0].arn : null
}

output "alb_controller_role_arn" {
  description = "ARN of the AWS Load Balancer Controller IAM role"
  value       = var.enable_irsa ? aws_iam_role.alb_controller[0].arn : null
}

output "vpc_id" {
  description = "VPC ID used by the EKS cluster"
  value       = local.vpc_id
}

# Route53 Hosted Zone Outputs
output "hosted_zone_ids" {
  description = "Map of domain names to hosted zone IDs"
  value = merge(
    { for domain, zone in aws_route53_zone.cluster_zones : domain => zone.zone_id },
    { for subdomain, zone in aws_route53_zone.cluster_subdomains : "${subdomain}.${var.primary_domain}" => zone.zone_id }
  )
}

output "hosted_zone_name_servers" {
  description = "Map of domain names to name servers"
  value = merge(
    { for domain, zone in aws_route53_zone.cluster_zones : domain => zone.name_servers },
    { for subdomain, zone in aws_route53_zone.cluster_subdomains : "${subdomain}.${var.primary_domain}" => zone.name_servers }
  )
}

output "all_managed_zone_ids" {
  description = "All zone IDs managed by this module (created + external)"
  value       = local.all_zone_ids
}

output "external_dns_domains" {
  description = "All domains configured for external-dns"
  value       = local.all_domains
}

output "load_balancer_controller_role_arn" {
  description = "ARN of the AWS Load Balancer Controller IAM role (alias for backward compatibility)"
  value       = var.enable_irsa && var.enable_load_balancer_controller ? aws_iam_role.alb_controller[0].arn : null
}
