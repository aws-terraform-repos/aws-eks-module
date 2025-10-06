# Copilot Instructio## Key Features
- **VPC Discovery**: Module can automatically discover VPC by name tag or custom tags, or accept explicit VPC ID
- **Subnet Discovery**: Module can automatically discover subnets by tags (default: kubernetes.io/role/internal-elb), or accept explicit subnet IDs
- **IRSA Support**: Module includes IAM Roles for Service Accounts (IRSA) for secure pod-to-AWS communication
- **Security Groups**: Dedicated security groups with configurable CIDR restrictions
- **EBS CSI Driver**: Properly configured with required IAM permissions
- **Flexible Configuration**: Three approaches for VPC/subnet selection to fit different use cases for aws-eks-module

## Overview
This repository defines a reusable Terraform module for provisioning AWS EKS (Elastic Kubernetes Service) clusters. The codebase is organized for clarity and modularity, supporting customization via variables and outputs.

## Key Files & Structure
- `main.tf`: Core logic for EKS cluster provisioning, including resource definitions.
- `variables.tf`: Declares all configurable variables for the module.
- `outputs.tf`: Exposes key outputs (e.g., cluster name, endpoint, kubeconfig).
- `iam.tf`: IAM roles and policies required for EKS and worker nodes.
- `data.tf`: Data sources for dynamic lookups (e.g., AMIs, VPCs).
- `versions.tf`: Provider requirements and version constraints.
- `examples/`: Example usage of the module with existing infrastructure.

## Patterns & Conventions
- **Module Usage**: The root directory is the module; the `examples/` folder contains usage examples.
- **VPC Discovery**: Supports three methods - by name tag, by custom tags, or explicit IDs for flexibility
- **Subnet Discovery**: Uses tags to find appropriate subnets (default: private subnets with kubernetes.io/role/internal-elb)
- **Variable Naming**: Follows Terraform snake_case. Required variables are documented in `variables.tf`.
- **Outputs**: Only expose values needed by consumers; keep outputs minimal and meaningful.
- **IAM**: All IAM resources are isolated in `iam.tf` for clarity and reuse.
- **Data Sources**: Use `data.tf` for all lookups to keep logic DRY and maintainable.
- **IRSA Support**: Module includes IAM Roles for Service Accounts (IRSA) for secure pod-to-AWS communication.
- **Security Groups**: Dedicated security groups with configurable CIDR restrictions.

## Developer Workflows
- **Initialize**: `terraform init`
- **Plan**: `terraform plan -var-file=yourvars.tfvars`
- **Apply**: `terraform apply -var-file=yourvars.tfvars`
- **Destroy**: `terraform destroy -var-file=yourvars.tfvars`
- **Validate**: `terraform validate`
- **Format**: `terraform fmt`

## Integration Points
- **AWS**: Requires AWS credentials (via environment or profile).
- **Kubernetes**: Outputs kubeconfig for cluster access.
- **IAM**: Integrates with AWS IAM for RBAC and node permissions.

## Project-Specific Notes
- Keep all resource names and tags parameterized for multi-environment support.
- Do not hardcode ARNs, VPC IDs, or AMI IDs; use variables or data sources.
- Example usage in `examples/` should be kept up-to-date with module changes.
- IRSA is enabled by default but can be disabled via `enable_irsa = false`.
- EBS CSI driver requires IRSA to function properly with service account roles.
- Security groups use configurable CIDR blocks for API server access control.

## Example: Adding a New Output
To expose a new EKS attribute:
1. Add the output in `outputs.tf`:
   ```hcl
   output "cluster_version" {
     value = aws_eks_cluster.this.version
   }
   ```
2. Reference it in your consumer configuration as `module.eks.cluster_version`.

---
For questions, review `README.md` and the example in `examples/`.
