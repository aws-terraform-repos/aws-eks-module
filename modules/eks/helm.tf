# Note: Helm deployments require proper provider configuration in the consumer module
# These resources are commented out to avoid provider dependency issues
# Users should deploy ExternalDNS and AWS Load Balancer Controller manually or 
# configure Helm provider in their root module

# Example Helm deployment for AWS Load Balancer Controller:
# resource "helm_release" "aws_load_balancer_controller" {
#   count = var.enable_load_balancer_controller ? 1 : 0
#   name       = "aws-load-balancer-controller"
#   repository = "https://aws.github.io/eks-charts"
#   chart      = "aws-load-balancer-controller"
#   namespace  = "kube-system"
#   values = [
#     "clusterName=${aws_eks_cluster.this.name}",
#     "serviceAccount.create=true",
#     "serviceAccount.name=aws-load-balancer-controller",
#     "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn=${var.enable_irsa ? aws_iam_role.alb_controller[0].arn : ""}",
#     "region=${data.aws_region.current.name}",
#     "vpcId=${local.vpc_id}"
#   ]
# }

# Example Helm deployment for ExternalDNS:
# resource "helm_release" "external_dns" {
#   count = var.enable_external_dns ? 1 : 0
#   name       = "external-dns"
#   repository = "https://kubernetes-sigs.github.io/external-dns/"
#   chart      = "external-dns"
#   namespace  = "kube-system"
#   values = [
#     "serviceAccount.create=true",
#     "serviceAccount.name=external-dns",
#     "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn=${var.enable_irsa ? aws_iam_role.external_dns[0].arn : ""}",
#     "provider=aws",
#     "sources={${join(",", var.external_dns_source)}}",
#     "domainFilters={${join(",", local.all_domains)}}",
#     "zoneIdFilters={${join(",", local.all_zone_ids)}}",
#     "policy=${var.external_dns_policy}",
#     "logLevel=${var.external_dns_log_level}",
#     "registry=txt",
#     "txtPrefix=external-dns-"
#   ]
# }
