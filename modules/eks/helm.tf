# Helm deployments for AWS Load Balancer Controller and ExternalDNS
# These resources deploy the controllers automatically when enabled

# Wait for cluster to be ready before deploying Helm charts
resource "time_sleep" "wait_for_cluster" {
  depends_on      = [aws_eks_cluster.this, aws_eks_node_group.this]
  create_duration = "30s"
}

# AWS Load Balancer Controller Helm Release
resource "helm_release" "aws_load_balancer_controller" {
  count = var.enable_helm_deployments && var.enable_load_balancer_controller ? 1 : 0

  depends_on = [
    time_sleep.wait_for_cluster,
    aws_iam_role.alb_controller,
    aws_eks_node_group.this
  ]

  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = var.load_balancer_controller_chart_version
  timeout    = var.helm_timeout
  wait       = var.wait_for_ready

  values = [
    yamlencode({
      clusterName = aws_eks_cluster.this.name
      serviceAccount = {
        create = true
        name   = "aws-load-balancer-controller"
        annotations = {
          "eks.amazonaws.com/role-arn" = var.enable_irsa ? aws_iam_role.alb_controller[0].arn : ""
        }
      }
      region = data.aws_region.current.name
      vpcId  = local.vpc_id
      image = {
        tag = "v2.8.3"
      }
    })
  ]
}

# ExternalDNS Helm Release
resource "helm_release" "external_dns" {
  count = var.enable_helm_deployments && var.enable_external_dns ? 1 : 0

  depends_on = [
    time_sleep.wait_for_cluster,
    aws_iam_role.external_dns,
    aws_eks_node_group.this
  ]

  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  namespace  = "kube-system"
  version    = var.external_dns_chart_version
  timeout    = var.helm_timeout
  wait       = var.wait_for_ready

  values = [
    yamlencode({
      serviceAccount = {
        create = true
        name   = "external-dns"
        annotations = {
          "eks.amazonaws.com/role-arn" = var.enable_irsa ? aws_iam_role.external_dns[0].arn : ""
        }
      }
      provider      = var.external_dns_provider
      sources       = var.external_dns_source
      domainFilters = local.all_domains
      zoneIdFilters = local.all_zone_ids
      policy        = var.external_dns_policy
      logLevel      = var.external_dns_log_level
      registry      = "txt"
      txtPrefix     = "external-dns-"
      txtOwnerId    = var.external_dns_txt_owner_id != null ? var.external_dns_txt_owner_id : var.cluster_name
      interval      = "1m"
    })
  ]
}
