# Simple EKS Cluster Example

This is the simplest way to deploy an EKS cluster using this module. You only need to provide a cluster name, and the module will handle all the discovery and configuration automatically.

## What This Example Does

- **Minimal Configuration**: Only requires a cluster name
- **Automatic VPC Discovery**: Uses the default VPC in your account
- **Smart Subnet Selection**: Automatically finds private subnets tagged with `kubernetes.io/role/internal-elb = "1"`
- **Default Node Group**: Creates a managed node group with sensible defaults (2x t3.medium instances)
- **Security Best Practices**: Configures all necessary IAM roles, security groups, and IRSA
- **Essential Add-ons**: Installs VPC-CNI, CoreDNS, kube-proxy, and EBS CSI driver

## Prerequisites

1. AWS CLI configured with appropriate permissions
2. A VPC with private subnets tagged with `kubernetes.io/role/internal-elb = "1"`
3. Terraform >= 1.0

## Quick Start

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Deploy the cluster
terraform apply

# Configure kubectl (use the output command)
aws eks update-kubeconfig --region us-east-1 --name simple-eks-cluster
```

## Customization

If you need to specify a particular VPC, uncomment and modify this line in `main.tf`:

```hcl
vpc_name = "my-vpc"  # Replace with your VPC name
```

## Clean Up

```bash
terraform destroy
```

## Default Configuration

| Setting | Value |
|---------|--------|
| Kubernetes Version | 1.34 |
| Node Instance Type | t3.medium |
| Node Count | 2 (desired), 1 (min), 4 (max) |
| IRSA | Enabled |
| Private Endpoint | Enabled |
| Public Endpoint | Enabled |
| Cluster Logging | All types enabled |