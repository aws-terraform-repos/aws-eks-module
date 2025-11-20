# EKS Cluster with Argo CD GitOps (On-Demand Nodes)

This example shows how to deploy an EKS cluster backed by on-demand nodes with **Argo CD** installed via the module's Helm automation.

## 🎯 What This Example Provides
- **EKS + IRSA**: Production-ready cluster with IAM Roles for Service Accounts
- **Argo CD**: GitOps control plane installed by Terraform with a LoadBalancer service for the UI/API
- **AWS Load Balancer Controller & ExternalDNS**: Ingress-ready with DNS automation
- **Route53 (optional)**: Automated hosted zone creation if desired
- **On-Demand Nodes**: Stable capacity for production-style workloads

## 🚀 Quick Start
1) Update `terraform.tfvars` with your VPC/subnet details, CIDR for API access, and (optionally) Route53 domains. Keep `enable_helm_deployments = true` and `enable_argo_cd = true`.
2) Deploy:
```bash
terraform init
terraform plan
terraform apply
```
3) Configure `kubectl`:
```bash
terraform output kubeconfig_command
# run the printed command, e.g.:
aws eks update-kubeconfig --region us-east-1 --name argo-cd-eks-cluster
```
4) Get Argo CD endpoint and password:
```bash
kubectl get svc -n argocd argocd-server
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```
5) Log in to the Argo CD UI using the `EXTERNAL-IP` from the service and the password above (user: `admin`). Change the password after first login.

## 🔧 Notable Settings
- Default chart version pinned in `terraform.tfvars` (`argo_cd_chart_version`) and `argo_cd_values.server.service.type = "LoadBalancer"` with NLB annotations for internet-facing access.
- ExternalDNS and AWS Load Balancer Controller are enabled so Ingresses and Services can be published with DNS records when Route53 is configured.
- Node groups use `AL2023_x86_64_STANDARD` AMI and on-demand capacity for predictable performance.

## ✅ Verification
```bash
kubectl get nodes
kubectl get pods -n kube-system
kubectl get pods -n argocd
terraform output helm_argo_cd_status
```

## 🧹 Cleanup
```bash
terraform destroy
```
