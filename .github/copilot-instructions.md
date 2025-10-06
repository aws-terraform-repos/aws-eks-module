# Copilot Instructions for aws-eks-module

## Overview
This repository defines a reusable Terraform module for provisioning AWS EKS (Elastic Kubernetes Service) clusters. The codebase is organized for clarity and modularity, supporting customization via variables and outputs.

## Key Files & Structure
- `main.tf`: Core logic for EKS cluster provisioning, including resource definitions.
- `variables.tf`: Declares all configurable variables for the module.
- `outputs.tf`: Exposes key outputs (e.g., cluster name, endpoint, kubeconfig).
- `iam.tf`: IAM roles and policies required for EKS and worker nodes.
- `data.tf`: Data sources for dynamic lookups (e.g., AMIs, VPCs).
- `eks-terraform/`: Example or consumer usage of the module (contains its own `main.tf`).

## Patterns & Conventions
- **Module Usage**: The root directory is the module; subfolders like `eks-terraform/` are for examples or integration tests.
- **Variable Naming**: Follows Terraform snake_case. Required variables are documented in `variables.tf`.
- **Outputs**: Only expose values needed by consumers; keep outputs minimal and meaningful.
- **IAM**: All IAM resources are isolated in `iam.tf` for clarity and reuse.
- **Data Sources**: Use `data.tf` for all lookups to keep logic DRY and maintainable.

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
- Example usage in `eks-terraform/` should be kept up-to-date with module changes.

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
For questions, review `README.md` and the example in `eks-terraform/`.
