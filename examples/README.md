# EKS Module Examples

This directory contains examples showing different ways to use the AWS EKS Terraform module. Each example is in its own directory with a complete configuration and documentation.

## Available Examples

### 🚀 [Simple Cluster](./simple-cluster/)
**Perfect for getting started quickly**

The simplest way to deploy an EKS cluster. Just provide a cluster name and let the module handle all the discovery and configuration automatically.

- **Complexity**: Beginner
- **Configuration**: Minimal (cluster name only)
- **VPC Discovery**: Automatic (uses default VPC)
- **Subnet Discovery**: Automatic (tagged subnets)
- **Use Case**: Development, testing, quick experiments

### 🏷️ [VPC Name Discovery](./vpc-name-discovery/)
**When you know your VPC's name**

Deploy an EKS cluster by specifying your VPC's Name tag. Great when you have well-named VPCs but want automatic subnet discovery.

- **Complexity**: Beginner
- **Configuration**: VPC name + optional customizations
- **VPC Discovery**: By Name tag
- **Subnet Discovery**: Automatic (tagged subnets)
- **Use Case**: Organized environments with clear naming conventions

### 🔖 [Tag-Based Discovery](./tag-based-discovery/)
**For advanced tagging strategies**

Discover both VPC and subnets using custom tags. Perfect for complex environments with sophisticated tagging strategies.

- **Complexity**: Intermediate
- **Configuration**: Custom tag mappings
- **VPC Discovery**: Custom tags
- **Subnet Discovery**: Custom tags
- **Use Case**: Enterprise environments with complex tagging strategies

### 🎯 [Explicit IDs](./explicit-ids/)
**Maximum control and precision**

Deploy using explicit VPC and subnet IDs when you need precise control over resource selection.

- **Complexity**: Advanced
- **Configuration**: Explicit resource IDs + advanced settings
- **VPC Discovery**: None (explicit ID)
- **Subnet Discovery**: None (explicit IDs)
- **Use Case**: CI/CD pipelines, strict compliance requirements, multi-account setups

## Quick Comparison

| Example | VPC Selection | Subnet Selection | Configuration Complexity | Best For |
|---------|---------------|------------------|-------------------------|----------|
| **Simple Cluster** | Auto (default) | Auto (tagged) | Minimal | Getting started |
| **VPC Name Discovery** | Name tag | Auto (tagged) | Low | Named VPCs |
| **Tag-Based Discovery** | Custom tags | Custom tags | Medium | Complex tagging |
| **Explicit IDs** | Explicit ID | Explicit IDs | High | Precise control |

## Getting Started

1. **Choose an example** based on your requirements and infrastructure setup
2. **Navigate to the example directory**: `cd examples/<example-name>/`
3. **Read the README**: Each example has detailed instructions
4. **Customize the configuration**: Update variables to match your environment
5. **Deploy**: Run `terraform init`, `terraform plan`, and `terraform apply`

## Common Prerequisites

All examples require:
- AWS CLI configured with appropriate permissions
- Terraform >= 1.0
- A VPC with appropriate subnets (specifics vary by example)

## Module Features

All examples include these features by default:
- ✅ **IRSA Support**: IAM Roles for Service Accounts
- ✅ **Security Groups**: Properly configured cluster and node security groups
- ✅ **Essential Add-ons**: VPC-CNI, CoreDNS, kube-proxy, EBS CSI driver
- ✅ **Managed Node Groups**: Auto-scaling worker nodes
- ✅ **Cluster Logging**: Control plane logging enabled
- ✅ **Latest Kubernetes**: Support for versions 1.28-1.34

## Need Help?

- Check the main [README.md](../README.md) for module documentation
- Review the [Copilot Instructions](../.github/copilot-instructions.md) for development guidelines
- Each example directory has its own detailed README with specific instructions