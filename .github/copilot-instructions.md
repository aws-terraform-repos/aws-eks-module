# Copilot Instructions

## Key Features
- **VPC Discovery**: Module can automatically discover VPC by name tag or custom tags, or accept explicit VPC ID
- **Subnet Discovery**: Module can automatically discover subnets by tags (default: kubernetes.io/role/internal-elb), or accept explicit subnet IDs
- **IRSA Support**: Module includes IAM Roles for Service Accounts (IRSA) for secure pod-to-AWS communication
- **Security Groups**: Dedicated security groups with configurable CIDR restrictions and optional SSH access
- **EBS CSI Driver**: Properly configured with required IAM permissions and IRSA support
- **VPC CNI Enhancement**: Dedicated IRSA role for enhanced network security
- **Add-on Version Management**: Automatic version management for all EKS add-ons
- **Flexible Configuration**: Three approaches for VPC/subnet selection to fit different use cases

## Overview
This repository defines a reusable Terraform module for provisioning AWS EKS (Elastic Kubernetes Service) clusters. The codebase is organized for clarity and modularity, supporting customization via variables and outputs.

## Key Files & Structure
- `main.tf`: Core logic for EKS cluster provisioning, including resource definitions and add-ons.
- `variables.tf`: Declares all configurable variables for the module.
- `outputs.tf`: Exposes key outputs (e.g., cluster name, endpoint, IRSA role ARNs).
- `iam.tf`: IAM roles and policies required for EKS, worker nodes, and service accounts.
- `data.tf`: Data sources for dynamic lookups (e.g., AMIs, VPCs, add-on versions).
- `versions.tf`: Provider requirements and version constraints.
- `examples/`: Complete working examples demonstrating different usage patterns.

## Examples Structure
- **simple-cluster/**: Minimal configuration for quick deployment
- **vpc-name-discovery/**: VPC discovery by name tag
- **tag-based-discovery/**: VPC and subnet discovery by custom tags
- **explicit-ids/**: Explicit VPC and subnet IDs for maximum control

## Patterns & Conventions
- **Module Usage**: The root directory is the module; the `examples/` folder contains complete usage examples.
- **VPC Discovery**: Supports three methods - by name tag, by custom tags, or explicit IDs for flexibility
- **Subnet Discovery**: Uses tags to find appropriate subnets (default: private subnets with kubernetes.io/role/internal-elb)
- **Variable Naming**: Follows Terraform snake_case. Required variables are documented in `variables.tf`.
- **Outputs**: Only expose values needed by consumers; keep outputs minimal and meaningful.
- **IAM**: All IAM resources are isolated in `iam.tf` for clarity and reuse.
- **Data Sources**: Use `data.tf` for all lookups to keep logic DRY and maintainable.
- **IRSA Support**: Module includes IAM Roles for Service Accounts (IRSA) for secure pod-to-AWS communication.
- **Security Groups**: Dedicated security groups with configurable CIDR restrictions and optional SSH access.
- **Add-on Management**: Automatic version management with proper conflict resolution.

## Developer Workflows
- **Task Runner**: Use `task test-all` for complete validation (requires [Task](https://taskfile.dev/))
- **Initialize**: `terraform init`
- **Plan**: `terraform plan -var-file=yourvars.tfvars`
- **Apply**: `terraform apply -var-file=yourvars.tfvars`
- **Destroy**: `terraform destroy -var-file=yourvars.tfvars`
- **Validate**: `terraform validate`
- **Format**: `terraform fmt`

## Taskfile Usage
This repository includes a comprehensive Taskfile for streamlined development:
- `task test-all`: Complete test suite (format, validate, plan)
- `task validate-examples`: Validate all example configurations
- `task plan-examples`: Plan all examples for syntax checking
- `task clean`: Clean all Terraform state and cache files
- See [TASKFILE.md](../TASKFILE.md) for complete usage guide

## Integration Points
- **AWS**: Requires AWS credentials (via environment or profile).
- **Kubernetes**: Outputs kubeconfig for cluster access.
- **IAM**: Integrates with AWS IAM for RBAC and node permissions.

## Project-Specific Notes
- Keep all resource names and tags parameterized for multi-environment support.
- Do not hardcode ARNs, VPC IDs, or AMI IDs; use variables or data sources.
- All examples in `examples/` are complete and working configurations.
- IRSA is enabled by default but can be disabled via `enable_irsa = false`.
- EBS CSI driver and VPC CNI both use dedicated IRSA roles for enhanced security.
- Security groups use configurable CIDR blocks for API server access control.
- SSH access to worker nodes is disabled by default for security.
- Add-ons automatically use compatible versions unless explicitly overridden.

## Example Development Guidelines
When creating new examples:
1. Include complete Terraform configuration that can be deployed independently
2. Add comprehensive README.md with usage instructions
3. Use realistic variable values and document all requirements
4. Include expected outputs and validation steps
5. Test thoroughly before adding to the repository

## Testing Examples
Each example should be tested with:
```bash
cd examples/<example-name>
terraform init
terraform validate
terraform plan
```

## Example: Adding a New Output
To expose a new EKS attribute:
1. Add the output in `outputs.tf`:
   ```hcl
   output "cluster_version" {
     description = "The Kubernetes version for the cluster"
     value = aws_eks_cluster.this.version
   }
   ```
2. Reference it in your consumer configuration as `module.eks.cluster_version`.

---
For questions, review `README.md` and the working examples in `examples/`.
