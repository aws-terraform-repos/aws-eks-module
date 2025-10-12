# Copilot Instructions

- **Always edit files directly**: When code changes are needed, use file editing tools to make actual changes to the codebase.
- **Never provide code snippets in chat**: Instead of showing code in responses, create or modify files using appropriate tools.
- **Use multi-file operations**: When multiple files need updates, use batch editing tools for efficiency.
- **Validate changes**: After making code changes, run validation commands and **wait for the output to confirm correctness before proceeding**. Do not rush or proceed to the next step until the output is received and verified.
- **Create working examples**: When demonstrating usage, create actual example files rather than showing inline code.
  
**When a request for changes is made, always update the specific files directly using file editing tools and do not print code or configuration in the chat window. Think before making output or assumptions.**

**Always use any tool needed to perform research and first search the internet to find if there is any solution available before making changes. Use the fetch tool to perform this research.**

**Always double check your work before considering a task complete. Do not hallucinate and make sure the changes you make will work. If needed, think twice and double check before making any changes.**
- **Always edit files directly**: When code changes are needed, use file editing tools to make actual changes to the codebase
- **Never provide code snippets in chat**: Instead of showing code in responses, create or modify files using appropriate tools
- **Use multi-file operations**: When multiple files need updates, use batch editing tools for efficiency
- **Validate changes**: After making code changes, run validation commands and **wait for the output to confirm correctness before proceeding**. Do not rush or proceed to the next step until the output is received and verified.
- **Create working examples**: When demonstrating usage, create actual example files rather than showing inline code

## Research and Information Guidelines
- **Use internet search tools**: Always search for the latest information, best practices, and current versions
- **Verify current versions**: Check for the latest EKS, Terraform provider, and add-on versions before making recommendations
- **Stay updated on AWS changes**: Research recent AWS EKS updates, new features, and deprecation notices
- **Reference official documentation**: Use web search to find and reference the most current AWS and Terraform documentation
- **Check for security updates**: Search for latest security best practices and vulnerability information
- **Validate compatibility**: Research compatibility between different component versions before implementing

## Key Features
- **Route53 Integration**: Automatic hosted zone creation and management for DNS automation
- **ExternalDNS Support**: Automatic DNS record management for Kubernetes services and ingresses
- **AWS Load Balancer Controller**: Integration with proper IRSA configuration for ALB/NLB management
- **VPC Discovery**: Module can automatically discover VPC by name tag, custom tags, or accept explicit VPC ID
- **Subnet Discovery**: Module can automatically discover subnets by tags (default: kubernetes.io/role/internal-elb), or accept explicit subnet IDs
- **IRSA Support**: Module includes IAM Roles for Service Accounts (IRSA) for secure pod-to-AWS communication
- **Security Groups**: Dedicated security groups with configurable CIDR restrictions and optional SSH access
- **EBS CSI Driver**: Properly configured with required IAM permissions and IRSA support
- **VPC CNI Enhancement**: Dedicated IRSA role for enhanced network security
- **Add-on Version Management**: Automatic version management for all EKS add-ons with conflict resolution
- **Helm Deployment Support**: Optional automated deployment of critical cluster components
- **Multi-Environment Support**: Comprehensive tagging and configuration for different environments

## Overview
This repository defines a reusable Terraform module for provisioning AWS EKS (Elastic Kubernetes Service) clusters with integrated Route53 DNS automation. The codebase is organized with a centralized module structure for clarity and modularity, supporting customization via variables and outputs. All deployments are organized in the examples directory for different use cases.

## Repository Structure
```
aws-eks-module/
├── modules/eks/          # 🎯 Main EKS module (centralized)
│   ├── main.tf          # Core EKS resources, security groups, and add-ons
│   ├── variables.tf     # All module input variables
│   ├── outputs.tf       # Module outputs for consumers
│   ├── iam.tf          # IAM roles, policies, and IRSA configuration
│   ├── data.tf         # Data sources for VPC/subnet discovery and add-on versions
│   ├── route53.tf      # Route53 hosted zones and DNS management
│   ├── helm.tf         # Helm deployment configurations
│   └── versions.tf     # Provider version constraints
├── examples/            # 📖 Complete deployment examples
│   ├── fargate/        # Fargate-specific configurations
│   ├── flux-cd/        # GitOps with Flux CD integration
│   ├── on-demand/      # On-demand instance configurations
│   └── spot/           # Spot instance configurations
├── manifests/          # 🎨 Sample Kubernetes manifests with DNS
├── README.md           # Main documentation
├── TASKFILE.md         # Development workflow guide
├── Taskfile.yml        # Task automation
├── CHANGELOG.md        # Version history and changes
├── MODULE-USAGE.md     # Guide for using module in other projects
└── FLUX-CD-IMPLEMENTATION.md  # GitOps implementation guide
```

## Key Files & Structure
- **`modules/eks/main.tf`**: Core logic for EKS cluster provisioning, including resource definitions and add-ons.
- **`modules/eks/variables.tf`**: Declares all configurable variables for the module.
- **`modules/eks/outputs.tf`**: Exposes key outputs (e.g., cluster name, endpoint, IRSA role ARNs).
- **`modules/eks/iam.tf`**: IAM roles and policies required for EKS, worker nodes, and service accounts.
- **`modules/eks/data.tf`**: Data sources for dynamic lookups (e.g., AMIs, VPCs, add-on versions).
- **`modules/eks/route53.tf`**: Route53 hosted zone creation and management for DNS automation.
- **`modules/eks/helm.tf`**: Helm deployment configurations for ExternalDNS and Load Balancer Controller.
- **`modules/eks/versions.tf`**: Provider requirements and version constraints.
- **`examples/`**: Complete deployment examples for different scenarios (Fargate, Spot, GitOps).
- **`manifests/`**: Sample Kubernetes manifests demonstrating DNS integration.

## Patterns & Conventions
- **Module Usage**: The centralized module is in `modules/eks/`; examples in the `examples/` directory provide complete deployment configurations.
- **VPC Discovery**: Supports three methods - by name tag, by custom tags, or explicit IDs for flexibility
- **Subnet Discovery**: Uses tags to find appropriate subnets (default: private subnets with kubernetes.io/role/internal-elb)
- **Variable Naming**: Follows Terraform snake_case. Required variables are documented in `modules/eks/variables.tf`.
- **Outputs**: Only expose values needed by consumers; keep outputs minimal and meaningful.
- **IAM**: All IAM resources are isolated in `modules/eks/iam.tf` for clarity and reuse.
- **Data Sources**: Use `modules/eks/data.tf` for all lookups to keep logic DRY and maintainable.
- **IRSA Support**: Module includes IAM Roles for Service Accounts (IRSA) for secure pod-to-AWS communication.
- **Security Groups**: Dedicated security groups with configurable CIDR restrictions and optional SSH access.
- **Add-on Management**: Automatic version management with proper conflict resolution.
- **Route53 Integration**: Automatic hosted zone creation and DNS record management.
- **Helm Deployments**: Optional automated deployment of ExternalDNS and AWS Load Balancer Controller.

## Developer Workflows
- **File-First Approach**: Always make changes directly to files using editing tools rather than showing code
- **Research-Driven Development**: Use web search to verify current best practices, versions, and compatibility before implementing
- **Task Runner**: Use `task test-all` for complete validation (requires Task)
- **Direct Editing**: Use file editing tools to modify configurations, variables, and resources
- **Batch Operations**: When multiple files need changes, use multi-file editing tools for efficiency
- **Validation**: After file changes, run `terraform validate` and `terraform plan` and **wait for the output to confirm correctness before proceeding**. Do not rush or proceed to the next step until the output is received and verified.
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
- `task plan`: Plan example configurations for syntax checking
- `task clean`: Clean all Terraform state and cache files
- `task format`: Format all Terraform files
- `task init-all`: Initialize all modules and examples
- See [TASKFILE.md](../TASKFILE.md) for complete usage guide

## Integration Points
- **AWS**: Requires AWS credentials (via environment or profile).
- **Kubernetes**: Outputs kubeconfig for cluster access.
- **IAM**: Integrates with AWS IAM for RBAC and node permissions.
- **Route53**: Manages DNS zones and records automatically.
- **Helm**: Optional automated deployment of cluster components.

## Project-Specific Notes
- **File-First Development**: Always create or edit actual files rather than providing code examples in chat
- **Direct Implementation**: When users request code changes, implement them directly in the appropriate files
- **Real Examples**: Use the `examples/` directory for working examples rather than showing inline code
- **Research Before Implementation**: Use web search to verify latest AWS EKS features, provider versions, and best practices
- **Security-First**: Always search for latest security recommendations and vulnerability updates before making changes
- Keep all resource names and tags parameterized for multi-environment support.
- Do not hardcode ARNs, VPC IDs, or AMI IDs; use variables or data sources.
- All complete working configurations are located in the `examples/` directory.
- IRSA is enabled by default but can be disabled via `enable_irsa = false`.
- EBS CSI driver and VPC CNI both use dedicated IRSA roles for enhanced security.
- Security groups use configurable CIDR blocks for API server access control.
- SSH access to worker nodes is disabled by default for security.
- Add-ons automatically use compatible versions unless explicitly overridden.
- Route53 hosted zones are optional but provide automatic DNS management when enabled.
- Helm deployments are optional and can be enabled for automated component installation.

## Module Usage Examples
When referencing the centralized module in configurations:

```hcl
module "eks" {
  source = "./modules/eks"  # From root level
  
  cluster_name = "my-cluster"
  vpc_name     = "my-vpc"
  
  # DNS Configuration
  create_hosted_zones = true
  hosted_zone_domains = ["example.com"]
  
  # Additional configuration as needed
}
```

## DNS Automation Features
- **Hosted Zone Creation**: Automatic Route53 hosted zone management
- **ExternalDNS Integration**: Automatic DNS record creation for ingresses and services
- **Load Balancer Controller**: AWS ALB/NLB integration with DNS
- **Subdomain Support**: Optional subdomain zone creation
- **Multi-Domain Support**: Support for multiple domains and zones

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

## Version Management
- **Current Version**: 1.0.0 (stable release)
- **Kubernetes Support**: 1.28+ (default: 1.32)
- **Provider Versions**: AWS ~> 5.0, Helm >= 2.0, Kubernetes >= 2.0
- **Add-on Versions**: Automatically managed with latest compatible versions
- **Upgrade Path**: See [CHANGELOG.md](../CHANGELOG.md) for version history

## Examples and Use Cases
- **Fargate**: `examples/fargate/` for serverless container workloads
- **GitOps**: `examples/flux-cd/` for GitOps workflow integration
- **Cost Optimization**: `examples/spot/` for spot instance configurations
- **Production**: `examples/on-demand/` for production-ready deployments

---
For questions, review `README.md` and the comprehensive examples in the `examples/` directory.
