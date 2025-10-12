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

# Flux CD Namespace
resource "kubernetes_namespace" "flux_system" {
  count = var.enable_helm_deployments && var.enable_flux_cd ? 1 : 0

  depends_on = [
    time_sleep.wait_for_cluster,
    aws_eks_node_group.this
  ]

  metadata {
    name = var.flux_cd_namespace
    labels = {
      "app.kubernetes.io/instance" = "flux-system"
      "app.kubernetes.io/part-of"  = "flux"
      "pod-security.kubernetes.io/warn"        = "restricted"
      "pod-security.kubernetes.io/warn-version" = "latest"
    }
  }
}

# Flux CD Helm Release
resource "helm_release" "flux_cd" {
  count = var.enable_helm_deployments && var.enable_flux_cd ? 1 : 0

  depends_on = [
    kubernetes_namespace.flux_system,
    time_sleep.wait_for_cluster,
    aws_iam_role.flux_cd,
    aws_eks_node_group.this
  ]

  name             = "flux2"
  repository       = "https://fluxcd-community.github.io/helm-charts"
  chart            = "flux2"
  namespace        = var.flux_cd_namespace
  version          = var.flux_cd_chart_version
  timeout          = var.helm_timeout
  wait             = var.wait_for_ready
  create_namespace = false  # We're creating it explicitly above

  values = [
    yamlencode({
      installCRDs = true

      # Source Controller
      sourceController = {
        create = true
        resources = {
          limits = {
            cpu    = "1000m"
            memory = "1Gi"
          }
          requests = {
            cpu    = "100m"
            memory = "64Mi"
          }
        }
      }

      # Kustomize Controller
      kustomizeController = {
        create = true
        resources = {
          limits = {
            cpu    = "1000m"
            memory = "1Gi"
          }
          requests = {
            cpu    = "100m"
            memory = "64Mi"
          }
        }
      }

      # Helm Controller
      helmController = {
        create = true
        resources = {
          limits = {
            cpu    = "1000m"
            memory = "1Gi"
          }
          requests = {
            cpu    = "100m"
            memory = "64Mi"
          }
        }
      }

      # Notification Controller
      notificationController = {
        create = true
        resources = {
          limits = {
            cpu    = "1000m"
            memory = "1Gi"
          }
          requests = {
            cpu    = "100m"
            memory = "64Mi"
          }
        }
      }

      # Image Reflector Controller (for image automation)
      imageReflectionController = {
        create = var.flux_cd_image_automation
        resources = {
          limits = {
            cpu    = "1000m"
            memory = "1Gi"
          }
          requests = {
            cpu    = "100m"
            memory = "64Mi"
          }
        }
      }

      # Image Automation Controller (for image automation)
      imageAutomationController = {
        create = var.flux_cd_image_automation
        resources = {
          limits = {
            cpu    = "1000m"
            memory = "1Gi"
          }
          requests = {
            cpu    = "100m"
            memory = "64Mi"
          }
        }
      }

      # Disable monitoring components (requires Prometheus Operator)
      prometheus = {
        podMonitor = {
          create = false
        }
        serviceMonitor = {
          create = false
        }
      }

      # Service Account with IRSA annotation
      serviceAccount = {
        create = true
        name   = "flux-cd"
        annotations = var.enable_irsa ? {
          "eks.amazonaws.com/role-arn" = aws_iam_role.flux_cd[0].arn
        } : {}
      }

      # Policies
      policies = {
        create = true
      }
    })
  ]
}

# Wait for Flux CD CRDs to be installed
resource "time_sleep" "wait_for_flux_crds" {
  count = var.enable_helm_deployments && var.enable_flux_cd ? 1 : 0

  depends_on = [helm_release.flux_cd]

  create_duration = "30s"
}

# Git Repository Source (if repository URL is provided)
resource "kubernetes_manifest" "flux_git_repository" {
  count = var.enable_helm_deployments && var.enable_flux_cd && var.flux_cd_git_repository_url != null ? 1 : 0

  depends_on = [
    helm_release.flux_cd,
    time_sleep.wait_for_flux_crds
  ]

  manifest = {
    apiVersion = "source.toolkit.fluxcd.io/v1"
    kind       = "GitRepository"
    metadata = {
      name      = "${var.cluster_name}-config"
      namespace = var.flux_cd_namespace
    }
    spec = merge({
      interval = var.flux_cd_git_repository_interval
      ref = {
        branch = var.flux_cd_git_repository_branch
      }
      url = var.flux_cd_git_repository_url
    }, var.flux_cd_git_auth_secret_name != null ? {
      secretRef = {
        name = var.flux_cd_git_auth_secret_name
      }
    } : {})
  }
}

# Kustomization (if repository URL is provided)
resource "kubernetes_manifest" "flux_kustomization" {
  count = var.enable_helm_deployments && var.enable_flux_cd && var.flux_cd_git_repository_url != null ? 1 : 0

  depends_on = [kubernetes_manifest.flux_git_repository]

  manifest = {
    apiVersion = "kustomize.toolkit.fluxcd.io/v1"
    kind       = "Kustomization"
    metadata = {
      name      = "${var.cluster_name}-config"
      namespace = var.flux_cd_namespace
    }
    spec = {
      interval = var.flux_cd_git_repository_interval
      path     = var.flux_cd_git_repository_path
      prune    = true
      sourceRef = {
        kind = "GitRepository"
        name = "${var.cluster_name}-config"
      }
      targetNamespace = "default"
      timeout         = "5m"
    }
  }
}
