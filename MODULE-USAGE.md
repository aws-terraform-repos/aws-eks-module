# Using AWS EKS Module v1.0.0 in Other Repositories

This document shows how to reference the tagged version of this EKS module in other Terraform projects.

## Example Usage

### Method 1: Using Git with Specific Tag (Recommended)

```hcl
# main.tf in your consumer repository
module "eks_cluster" {
  source = "git::https://github.com/aws-terraform-repos/aws-eks-module.git//modules/eks?ref=v1.0.0"

  # Required variables
  cluster_name = "production-eks"
  vpc_id       = "vpc-12345678"

  # Optional variables with your customizations
  cluster_version             = "1.31"
  node_group_instance_types   = ["t3.large", "t3.xlarge"]
  node_group_desired_size     = 3
  node_group_max_size         = 10
  node_group_min_size         = 1
  
  # Security configuration
  public_access_cidrs = ["203.0.113.0/24"]  # Your office IP range
  
  # DNS and Add-ons
  enable_external_dns             = true
  enable_load_balancer_controller = true
  primary_domain                  = "yourcompany.com"
  
  # Tagging
  tags = {
    Environment = "production"
    Team        = "platform"
    Project     = "main-application"
  }
}
```

### Method 2: Using Git with Module Subdirectory

```hcl
# For the complete root example (includes Route53 setup)
module "complete_eks_with_dns" {
  source = "git::https://github.com/aws-terraform-repos/aws-eks-module.git?ref=v1.0.0"

  # This uses the root main.tf which includes Route53 hosted zones
  cluster_name        = "staging-eks"
  primary_domain      = "staging.yourcompany.com"
  create_hosted_zones = true
  
  # VPC Discovery
  vpc_name = "staging-vpc"
  
  # Other configurations...
}
```

### Method 3: Using Terraform Registry (if published)

```hcl
# If the module is published to Terraform Registry
module "eks" {
  source  = "aws-terraform-repos/eks/aws"
  version = "1.0.0"

  cluster_name = "my-cluster"
  # ... other variables
}
```

## Version Pinning Best Practices

### 1. Always Pin to Specific Versions
```hcl
# ✅ Good - Explicit version
source = "git::https://github.com/aws-terraform-repos/aws-eks-module.git//modules/eks?ref=v1.0.0"

# ❌ Bad - Uses latest commit, can break unexpectedly
source = "git::https://github.com/aws-terraform-repos/aws-eks-module.git//modules/eks"
```

### 2. Use Semantic Versioning for Updates
```hcl
# Patch updates (bug fixes) - Safe to auto-update
source = "git::...?ref=v1.0.1"

# Minor updates (new features, backward compatible) - Review before updating
source = "git::...?ref=v1.1.0"

# Major updates (breaking changes) - Requires migration planning
source = "git::...?ref=v2.0.0"
```

### 3. Environment-Specific Versioning
```hcl
# Development - Can use latest stable
source = "git::...?ref=v1.0.0"

# Staging - Test new versions before production
source = "git::...?ref=v1.1.0"

# Production - Conservative, well-tested versions
source = "git::...?ref=v1.0.0"
```

## Outputs Available

```hcl
# Access module outputs
output "cluster_endpoint" {
  value = module.eks_cluster.cluster_endpoint
}

output "cluster_name" {
  value = module.eks_cluster.cluster_name
}

output "cluster_security_group_id" {
  value = module.eks_cluster.cluster_security_group_id
}

output "node_security_group_id" {
  value = module.eks_cluster.node_security_group_id
}

# IRSA role ARNs for service account bindings
output "external_dns_irsa_role_arn" {
  value = module.eks_cluster.external_dns_irsa_role_arn
}

output "load_balancer_controller_irsa_role_arn" {
  value = module.eks_cluster.load_balancer_controller_irsa_role_arn
}
```

## Upgrading Between Versions

### From v1.0.0 to v1.0.x (Patch Updates)
- Bug fixes only
- Safe to update without configuration changes
- Review CHANGELOG.md for specific fixes

### From v1.0.x to v1.x.0 (Minor Updates)
- New features added (backward compatible)
- May include new optional variables
- Review CHANGELOG.md for new capabilities

### From v1.x.x to v2.0.0 (Major Updates)
- Breaking changes possible
- Review migration guide in CHANGELOG.md
- Test thoroughly in non-production environments first
- May require configuration updates

## Common Integration Patterns

### Pattern 1: Multi-Environment Setup
```hcl
# environments/production/main.tf
module "prod_eks" {
  source = "git::https://github.com/aws-terraform-repos/aws-eks-module.git//modules/eks?ref=v1.0.0"
  
  cluster_name = "prod-${var.region}-eks"
  # Production-specific configuration
}

# environments/staging/main.tf  
module "staging_eks" {
  source = "git::https://github.com/aws-terraform-repos/aws-eks-module.git//modules/eks?ref=v1.1.0"
  
  cluster_name = "staging-${var.region}-eks"
  # Staging can test newer versions
}
```

### Pattern 2: Shared Module with Local Overrides
```hcl
# Use the tagged module as base
module "base_eks" {
  source = "git::https://github.com/aws-terraform-repos/aws-eks-module.git//modules/eks?ref=v1.0.0"
  
  cluster_name = var.cluster_name
  # ... base configuration
}

# Add additional resources specific to your needs
resource "aws_iam_role" "custom_service_role" {
  name = "${module.base_eks.cluster_name}-custom-role"
  # ... custom IAM configuration
}
```

## Troubleshooting

### Module Not Found
```bash
# Ensure you can access the repository
git ls-remote https://github.com/aws-terraform-repos/aws-eks-module.git

# Check available tags
git ls-remote --tags https://github.com/aws-terraform-repos/aws-eks-module.git
```

### Version Conflicts
```bash
# Clear Terraform cache if having issues
rm -rf .terraform/
terraform init
```

### Authentication Issues
```bash
# For private repositories, ensure SSH or token access
git config --list | grep github
```

---

For the complete list of available variables and outputs, see:
- [Module Variables](https://github.com/aws-terraform-repos/aws-eks-module/blob/v1.0.0/modules/eks/variables.tf)
- [Module Outputs](https://github.com/aws-terraform-repos/aws-eks-module/blob/v1.0.0/modules/eks/outputs.tf)
- [CHANGELOG](https://github.com/aws-terraform-repos/aws-eks-module/blob/v1.0.0/CHANGELOG.md)