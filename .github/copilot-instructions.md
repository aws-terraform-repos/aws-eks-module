# Copilot Instructions

## Code Modification Guidelines
- **Always edit files directly**: When code changes are needed, use file editing tools to make actual changes to the codebase
- **Never provide code snippets in chat**: Instead of showing code in responses, create or modify files using appropriate tools
- **Use multi-file operations**: When multiple files need updates, use batch editing tools for efficiency
- **Validate changes**: After making code changes, run validation commands to ensure correctness
- **Create working examples**: When demonstrating usage, create actual example files rather than showing inline code

## Research and Information Guidelines
- **Use internet search tools**: Always search for the latest information, best practices, and current versions
- **Verify current versions**: Check for the latest EKS, Terraform provider, and add-on versions before making recommendations
- **Stay updated on AWS changes**: Research recent AWS EKS updates, new features, and deprecation notices
- **Reference official documentation**: Use web search to find and reference the most current AWS and Terraform documentation
- **Check for security updates**: Search for latest security best practices and vulnerability information
- **Validate compatibility**: Research compatibility between different component versions before implementing

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
This repository defines a reusable Terraform module for provisioning AWS EKS (Elastic Kubernetes Service) clusters. The codebase is organized with a centralized module structure for clarity and modularity, supporting customization via variables and outputs.

## Repository Structure
```
aws-eks-module/
├── modules/eks/          # 🎯 Main EKS module (centralized)
│   ├── main.tf          # Core EKS resources, security groups, and add-ons
│   ├── variables.tf     # All module input variables
│   ├── outputs.tf       # Module outputs for consumers
│   ├── iam.tf          # IAM roles, policies, and IRSA configuration
│   ├── data.tf         # Data sources for VPC/subnet discovery and add-on versions
│   └── versions.tf     # Provider version constraints
├── main.tf             # 🚀 Root-level usage example
├── README.md           # Main documentation
├── TASKFILE.md         # Development workflow guide
└── Taskfile.yml        # Task automation
```

## Key Files & Structure
- **`modules/eks/main.tf`**: Core logic for EKS cluster provisioning, including resource definitions and add-ons.
- **`modules/eks/variables.tf`**: Declares all configurable variables for the module.
- **`modules/eks/outputs.tf`**: Exposes key outputs (e.g., cluster name, endpoint, IRSA role ARNs).
- **`modules/eks/iam.tf`**: IAM roles and policies required for EKS, worker nodes, and service accounts.
- **`modules/eks/data.tf`**: Data sources for dynamic lookups (e.g., AMIs, VPCs, add-on versions).
- **`modules/eks/versions.tf`**: Provider requirements and version constraints.
- **`main.tf`**: Root-level example showing how to use the centralized module.

## Patterns & Conventions
- **Module Usage**: The centralized module is in `modules/eks/`; the root-level `main.tf` provides a complete usage example.
- **VPC Discovery**: Supports three methods - by name tag, by custom tags, or explicit IDs for flexibility
- **Subnet Discovery**: Uses tags to find appropriate subnets (default: private subnets with kubernetes.io/role/internal-elb)
- **Variable Naming**: Follows Terraform snake_case. Required variables are documented in `modules/eks/variables.tf`.
- **Outputs**: Only expose values needed by consumers; keep outputs minimal and meaningful.
- **IAM**: All IAM resources are isolated in `modules/eks/iam.tf` for clarity and reuse.
- **Data Sources**: Use `modules/eks/data.tf` for all lookups to keep logic DRY and maintainable.
- **IRSA Support**: Module includes IAM Roles for Service Accounts (IRSA) for secure pod-to-AWS communication.
- **Security Groups**: Dedicated security groups with configurable CIDR restrictions and optional SSH access.
- **Add-on Management**: Automatic version management with proper conflict resolution.

## Developer Workflows
- **File-First Approach**: Always make changes directly to files using editing tools rather than showing code
- **Research-Driven Development**: Use web search to verify current best practices, versions, and compatibility before implementing
- **Task Runner**: Use `task test-all` for complete validation (requires [Task](https://taskfile.dev/))
- **Direct Editing**: Use file editing tools to modify configurations, variables, and resources
- **Batch Operations**: When multiple files need changes, use multi-file editing tools for efficiency
- **Validation**: After file changes, run `terraform validate` and `terraform plan` to verify correctness
- **Version Verification**: Always check for latest provider and add-on versions using web search
- **Initialize**: `terraform init` (in module or example directory)
- **Plan**: `terraform plan -var-file=yourvars.tfvars`
- **Apply**: `terraform apply -var-file=yourvars.tfvars`
- **Destroy**: `terraform destroy -var-file=yourvars.tfvars`
- **Format**: `terraform fmt` (or use task runner for batch formatting)

## Taskfile Usage
This repository includes a comprehensive Taskfile for streamlined development:
- `task test-all`: Complete test suite (format, validate, plan)
- `task validate`: Validate the main module
- `task plan`: Plan the root example for syntax checking
- `task clean`: Clean all Terraform state and cache files
- See [TASKFILE.md](../TASKFILE.md) for complete usage guide

## Integration Points
- **AWS**: Requires AWS credentials (via environment or profile).
- **Kubernetes**: Outputs kubeconfig for cluster access.
- **IAM**: Integrates with AWS IAM for RBAC and node permissions.

## Project-Specific Notes
- **File-First Development**: Always create or edit actual files rather than providing code examples in chat
- **Direct Implementation**: When users request code changes, implement them directly in the appropriate files
- **Real Examples**: Use the root-level `main.tf` as the primary working example rather than showing inline code
- **Research Before Implementation**: Use web search to verify latest AWS EKS features, provider versions, and best practices
- **Security-First**: Always search for latest security recommendations and vulnerability updates before making changes
- Keep all resource names and tags parameterized for multi-environment support.
- Do not hardcode ARNs, VPC IDs, or AMI IDs; use variables or data sources.
- The root-level `main.tf` is a complete and working configuration.
- IRSA is enabled by default but can be disabled via `enable_irsa = false`.
- EBS CSI driver and VPC CNI both use dedicated IRSA roles for enhanced security.
- Security groups use configurable CIDR blocks for API server access control.
- SSH access to worker nodes is disabled by default for security.
- Add-ons automatically use compatible versions unless explicitly overridden.

## Module Usage Examples
When referencing the centralized module in configurations:

```hcl
module "eks" {
  source = "./modules/eks"  # From root level
  
  cluster_name = "my-cluster"
  vpc_name     = "my-vpc"
  
  # Additional configuration as needed
}
```

## Example: Adding a New Output
To expose a new EKS attribute:
1. Edit the file `modules/eks/outputs.tf` directly using file editing tools to add:
   ```hcl
   output "cluster_version" {
     description = "The Kubernetes version for the cluster"
     value = aws_eks_cluster.this.version
   }
   ```
2. Reference it in your consumer configuration as `module.eks.cluster_version`.
3. Always use file editing tools rather than providing code snippets in responses.

---
For questions, review `README.md` and the working example in the root `main.tf`.
