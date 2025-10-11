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

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks.cluster_certificate_authority_data
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster for the OpenID Connect identity provider"
  value       = module.eks.cluster_oidc_issuer_url
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider if IRSA is enabled"
  value       = module.eks.oidc_provider_arn
}

output "flux_cd_role_arn" {
  description = "ARN of the Flux CD IAM role"
  value       = module.eks.flux_cd_role_arn
}

output "flux_cd_namespace" {
  description = "Kubernetes namespace where Flux CD is installed"
  value       = module.eks.flux_cd_namespace
}

output "kubeconfig_command" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${data.aws_region.current.name} --name ${module.eks.cluster_name}"
}

output "flux_cd_setup_instructions" {
  description = "Complete setup instructions for Flux CD"
  value       = <<-EOT
# Flux CD Setup Instructions for ${module.eks.cluster_name}

## 1. Configure kubectl
aws eks update-kubeconfig --region ${data.aws_region.current.name} --name ${module.eks.cluster_name}

## 2. Verify cluster access
kubectl get nodes

## 3. Check Flux CD installation
kubectl get pods -n flux-system

## 4. Create Git authentication secret (for private repositories)
kubectl create secret generic flux-git-auth \
  --from-file=identity=/path/to/your/ssh/private/key \
  --from-literal=known_hosts="$$(ssh-keyscan github.com)" \
  -n flux-system

## 5. Verify Flux CD resources
kubectl get gitrepositories -n flux-system
kubectl get kustomizations -n flux-system

## 6. Monitor reconciliation
flux get sources git
flux get kustomizations

## 7. Example repository structure
your-k8s-repo/
├── clusters/
│   └── flux-cd-eks-cluster/
│       ├── flux-system/
│       │   ├── gotk-components.yaml
│       │   ├── gotk-sync.yaml
│       │   └── kustomization.yaml
│       └── apps/
│           ├── base/
│           └── overlays/
├── infrastructure/
│   ├── controllers/
│   └── configs/
└── apps/
    ├── base/
    └── overlays/

## 8. Image automation (if enabled)
# Example ImageRepository
apiVersion: image.toolkit.fluxcd.io/v1beta2
kind: ImageRepository
metadata:
  name: webapp
  namespace: flux-system
spec:
  image: your-account.dkr.ecr.region.amazonaws.com/webapp
  interval: 1m

# Example ImagePolicy
apiVersion: image.toolkit.fluxcd.io/v1beta2
kind: ImagePolicy
metadata:
  name: webapp-policy
  namespace: flux-system
spec:
  imageRepositoryRef:
    name: webapp
  policy:
    semver:
      range: '>=1.0.0'

## 9. Useful commands
# Check Flux CD logs
kubectl logs -n flux-system -l app=source-controller
kubectl logs -n flux-system -l app=kustomize-controller

# Force reconciliation
flux reconcile source git flux-system
flux reconcile kustomization flux-system

# Suspend/resume reconciliation
flux suspend kustomization flux-system
flux resume kustomization flux-system
EOT
}

# Data source to get current region
data "aws_region" "current" {}
