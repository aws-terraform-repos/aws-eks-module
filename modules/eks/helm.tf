# Helm deployments for AWS Load Balancer Controller and ExternalDNS
# These resources deploy the controllers automatically when enabled
#
# READINESS STRATEGY:
# 1. EKS Cluster must be ACTIVE before node groups and Fargate profiles are created
# 2. Node groups and Fargate profiles must be ACTIVE before add-ons are installed
# 3. All add-ons (vpc-cni, kube-proxy, coredns, ebs-csi-driver) must be ready before Helm deployments
# 4. Cluster status is verified via data source before proceeding with Helm/kubectl operations
# 5. Configurable wait time (cluster_readiness_timeout) ensures cluster stability
# 6. Helm deployments have explicit wait=true and timeout configurations

# Wait for cluster and node groups to be fully ready before deploying Helm charts
resource "time_sleep" "wait_for_cluster" {
  depends_on = [
    aws_eks_cluster.this,
    aws_eks_node_group.this,
    aws_eks_fargate_profile.this,
    aws_eks_addon.vpc_cni,
    aws_eks_addon.kube_proxy,
    aws_eks_addon.coredns,
    aws_eks_addon.ebs_csi_driver
  ]
  create_duration = var.cluster_readiness_timeout

  triggers = {
    cluster_status   = aws_eks_cluster.this.status
    cluster_endpoint = aws_eks_cluster.this.endpoint
    # Force recreation if cluster is recreated
    cluster_arn = aws_eks_cluster.this.arn
  }
}

# AWS Load Balancer Controller Helm Release
resource "helm_release" "aws_load_balancer_controller" {
  count = var.enable_helm_deployments && var.enable_load_balancer_controller ? 1 : 0

  depends_on = [
    time_sleep.wait_for_cluster,
    data.aws_eks_cluster.cluster_status,
    aws_iam_role.alb_controller,
    aws_eks_node_group.this,
    aws_eks_addon.vpc_cni,
    aws_eks_addon.kube_proxy,
    aws_eks_addon.coredns
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
    data.aws_eks_cluster.cluster_status,
    aws_iam_role.external_dns,
    aws_eks_node_group.this,
    aws_eks_addon.vpc_cni,
    aws_eks_addon.kube_proxy,
    aws_eks_addon.coredns
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
    data.aws_eks_cluster.cluster_status,
    aws_eks_node_group.this,
    aws_eks_addon.vpc_cni,
    aws_eks_addon.kube_proxy,
    aws_eks_addon.coredns
  ]

  metadata {
    name = var.flux_cd_namespace
    labels = {
      "app.kubernetes.io/instance"              = "flux-system"
      "app.kubernetes.io/part-of"               = "flux"
      "pod-security.kubernetes.io/warn"         = "restricted"
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
    data.aws_eks_cluster.cluster_status,
    aws_iam_role.flux_cd,
    aws_eks_node_group.this,
    aws_eks_addon.vpc_cni,
    aws_eks_addon.kube_proxy,
    aws_eks_addon.coredns
  ]

  name             = "flux2"
  repository       = "https://fluxcd-community.github.io/helm-charts"
  chart            = "flux2"
  namespace        = var.flux_cd_namespace
  version          = var.flux_cd_chart_version
  timeout          = var.helm_timeout
  wait             = var.wait_for_ready
  create_namespace = false # We're creating it explicitly above

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

# Argo CD Namespace
resource "kubernetes_namespace" "argo_cd" {
  count = var.enable_helm_deployments && var.enable_argo_cd ? 1 : 0

  depends_on = [
    time_sleep.wait_for_cluster,
    data.aws_eks_cluster.cluster_status,
    aws_eks_node_group.this,
    aws_eks_addon.vpc_cni,
    aws_eks_addon.kube_proxy,
    aws_eks_addon.coredns
  ]

  metadata {
    name = var.argo_cd_namespace
    labels = {
      "app.kubernetes.io/name"     = "argocd"
      "app.kubernetes.io/instance" = "argocd"
    }
  }
}

# Argo CD Helm Release
resource "helm_release" "argo_cd" {
  count = var.enable_helm_deployments && var.enable_argo_cd ? 1 : 0

  depends_on = [
    kubernetes_namespace.argo_cd,
    time_sleep.wait_for_cluster,
    data.aws_eks_cluster.cluster_status,
    aws_eks_node_group.this,
    aws_eks_addon.vpc_cni,
    aws_eks_addon.kube_proxy,
    aws_eks_addon.coredns,
    # Wait for ALB controller webhook; if disabled count=0 this is a no-op
    helm_release.aws_load_balancer_controller
  ]

  name             = var.argo_cd_release_name
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = var.argo_cd_namespace
  version          = var.argo_cd_chart_version
  timeout          = var.helm_timeout
  wait             = var.wait_for_ready
  create_namespace = false
  replace          = true          # allow re-use if a failed release remains
  cleanup_on_fail  = true          # ensure failed installs are cleaned up

  values = [
    yamlencode(merge({
      crds = {
        install = true
      }
      server = {
        service = {
          type = "LoadBalancer"
          annotations = {
            "service.beta.kubernetes.io/aws-load-balancer-type"            = "nlb"
            "service.beta.kubernetes.io/aws-load-balancer-scheme"          = "internet-facing"
            "service.beta.kubernetes.io/aws-load-balancer-nlb-target-type" = "instance"
          }
        }
      }
    }, var.argo_cd_values))
  ]
}

resource "null_resource" "argo_cd_initial_password" {
  count = var.enable_helm_deployments && var.enable_argo_cd ? 1 : 0

  depends_on = [helm_release.argo_cd]

  provisioner "local-exec" {
    command = "kubectl -n ${var.argo_cd_namespace} get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo"
  }
}

data "kubernetes_secret" "argo_cd_initial_admin" {
  count = var.enable_helm_deployments && var.enable_argo_cd ? 1 : 0

  depends_on = [helm_release.argo_cd]

  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = var.argo_cd_namespace
  }
}

# Cluster Autoscaler Helm Release
resource "helm_release" "cluster_autoscaler" {
  count = var.enable_helm_deployments && var.enable_cluster_autoscaler ? 1 : 0

  depends_on = [
    time_sleep.wait_for_cluster,
    data.aws_eks_cluster.cluster_status,
    aws_iam_role.cluster_autoscaler,
    aws_eks_node_group.this,
    aws_eks_addon.vpc_cni,
    aws_eks_addon.kube_proxy,
    aws_eks_addon.coredns
  ]

  name       = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"
  version    = var.cluster_autoscaler_chart_version
  timeout    = var.helm_timeout
  wait       = var.wait_for_ready

  values = [
    yamlencode(merge({
      autoDiscovery = {
        clusterName = aws_eks_cluster.this.name
      }
      awsRegion     = data.aws_region.current.name
      cloudProvider = "aws"
      rbac = {
        create = true
        serviceAccount = {
          annotations = {
            "eks.amazonaws.com/role-arn" = var.enable_irsa ? aws_iam_role.cluster_autoscaler[0].arn : ""
          }
          create = true
          name   = "cluster-autoscaler"
        }
      }
      resources = {
        limits = {
          cpu    = "200m"
          memory = "512Mi"
        }
        requests = {
          cpu    = "100m"
          memory = "256Mi"
        }
      }
      extraArgs = {
        "scale-down-delay-after-add"  = "2m"
        "scale-down-unneeded-time"    = "2m"
        "scan-interval"               = "30s"
        "skip-nodes-with-system-pods" = "false"
        "balance-similar-node-groups" = "true"
        "expander"                    = "least-waste"
      }
    }, var.cluster_autoscaler_values))
  ]
}

# Metrics Server Helm Release
resource "helm_release" "metrics_server" {
  count = var.enable_helm_deployments && var.enable_metrics_server ? 1 : 0

  depends_on = [
    time_sleep.wait_for_cluster,
    data.aws_eks_cluster.cluster_status,
    aws_eks_node_group.this,
    aws_eks_addon.vpc_cni,
    aws_eks_addon.kube_proxy,
    aws_eks_addon.coredns
  ]

  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"
  version    = var.metrics_server_chart_version
  timeout    = var.helm_timeout
  wait       = var.wait_for_ready

  values = [
    yamlencode(merge({
      resources = {
        limits = {
          cpu    = "100m"
          memory = "200Mi"
        }
        requests = {
          cpu    = "50m"
          memory = "100Mi"
        }
      }
      args = [
        "--kubelet-insecure-tls",
        "--kubelet-preferred-address-types=InternalIP"
      ]
    }, var.metrics_server_values))
  ]
}
