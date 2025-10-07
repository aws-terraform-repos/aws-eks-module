# EKS Module

This directory contains the centralized AWS EKS Terraform module.

## Structure

```
modules/eks/
├── main.tf       # Core EKS resources, security groups, and add-ons
├── variables.tf  # All module input variables
├── outputs.tf    # Module outputs for consumers
├── iam.tf        # IAM roles, policies, and IRSA configuration
├── data.tf       # Data sources for VPC/subnet discovery and add-on versions
└── versions.tf   # Provider version constraints
```

## Module Features

- **EKS Cluster** with configurable Kubernetes version
- **Managed Node Groups** with auto-scaling
- **Essential Add-ons**: VPC CNI, CoreDNS, kube-proxy, EBS CSI driver
- **IRSA Support** for secure pod-to-AWS communication
- **Smart VPC/Subnet Discovery** with multiple methods
- **Security Groups** with best practices
- **IAM Roles** following least privilege principles

## Usage

```hcl
module "eks" {
  source = "./modules/eks"
  
  cluster_name = "my-cluster"
  vpc_name     = "my-vpc"
  
  # Additional configuration as needed
}
```

See the [main README](../../README.md) and root-level `main.tf` for complete usage patterns.