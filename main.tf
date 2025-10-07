# EKS cluster with integrated Route53 hosted zones for DNS automation
module "eks" {
  source = "./modules/eks"

  # Cluster Configuration
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  # VPC Discovery Configuration - Using name-based discovery for simplicity
  vpc_name = var.vpc_name
  vpc_tags = var.vpc_tags
  vpc_id   = var.vpc_id

  # Subnet Discovery Configuration - Default uses private subnets with ALB tag
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

  # Route53 and DNS Configuration
  create_hosted_zones    = var.create_hosted_zones
  hosted_zone_domains    = var.hosted_zone_domains
  primary_domain         = var.primary_domain
  create_subdomain_zones = var.create_subdomain_zones
  subdomain_zones        = var.subdomain_zones
  parent_zone_id         = var.parent_zone_id

  # External DNS and Load Balancer Configuration
  enable_load_balancer_controller = var.enable_load_balancer_controller
  enable_external_dns             = var.enable_external_dns
  external_dns_source             = var.external_dns_source
  external_dns_provider           = var.external_dns_provider
  external_dns_log_level          = var.external_dns_log_level

  # Helm Deployment Configuration
  enable_helm_deployments = var.enable_helm_deployments
  helm_timeout            = var.helm_timeout
  wait_for_ready          = var.wait_for_ready

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

# Route53 and DNS Outputs
output "hosted_zone_ids" {
  description = "Map of domain names to hosted zone IDs"
  value       = module.eks.hosted_zone_ids
}

output "hosted_zone_name_servers" {
  description = "Map of domain names to name servers"
  value       = module.eks.hosted_zone_name_servers
}

output "all_managed_zone_ids" {
  description = "All zone IDs managed by this module"
  value       = module.eks.all_managed_zone_ids
}

output "external_dns_domains" {
  description = "All domains configured for external-dns"
  value       = module.eks.external_dns_domains
}

output "load_balancer_controller_role_arn" {
  description = "ARN of the AWS Load Balancer Controller IAM role"
  value       = module.eks.load_balancer_controller_role_arn
}

# Deployment Instructions Output
output "deployment_instructions" {
  description = "Complete deployment instructions for DNS-enabled EKS cluster"
  value       = var.create_hosted_zones ? "EKS cluster with DNS automation deployed successfully! Check hosted_zone_name_servers output for domain configuration, then install Helm charts manually." : "EKS cluster deployed without hosted zones. Configure external DNS manually."
}

# Helm Installation Commands Output
output "helm_installation_commands" {
  description = "Commands to install required Helm charts"
  value       = <<-EOT
# Install AWS Load Balancer Controller
helm repo add eks https://aws.github.io/eks-charts
helm repo update
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=${module.eks.cluster_name} \
  --set serviceAccount.create=true \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"=${module.eks.load_balancer_controller_role_arn} \
  --set region=${data.aws_region.current.name} \
  --set vpcId=${module.eks.vpc_id}

# Install ExternalDNS
helm repo add external-dns https://kubernetes-sigs.github.io/external-dns/
helm repo update
helm install external-dns external-dns/external-dns \
  -n kube-system \
  --set serviceAccount.create=true \
  --set serviceAccount.name=external-dns \
  --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"=${module.eks.external_dns_role_arn} \
  --set provider=aws \
  --set sources='{${join(",", var.external_dns_source)}}' \
  --set policy=${var.external_dns_policy} \
  --set registry=txt \
  --set txtOwnerId=${var.external_dns_txt_owner_id}
EOT
}

# Data source to get current region
data "aws_region" "current" {}
