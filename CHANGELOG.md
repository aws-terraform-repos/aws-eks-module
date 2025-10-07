# Changelog

All notable changes to this AWS EKS Terraform module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-10-07

### Added
- **Initial stable release** of AWS EKS Terraform module
- **EKS Cluster Provisioning** with configurable Kubernetes versions
- **VPC Discovery** - Automatic VPC discovery by name tag, custom tags, or explicit VPC ID
- **Subnet Discovery** - Automatic subnet discovery with configurable tags
- **Route53 Integration** - Automatic hosted zone creation and management
- **ExternalDNS Support** - Automatic DNS record management for Kubernetes services and ingresses
- **AWS Load Balancer Controller** - Helm deployment with proper IRSA configuration
- **IAM Roles for Service Accounts (IRSA)** - Secure pod-to-AWS service communication
- **EBS CSI Driver** - With dedicated IRSA role for persistent volume support
- **VPC CNI Enhancement** - Dedicated IRSA role for network security
- **Security Groups** - Dedicated security groups with configurable CIDR restrictions
- **Node Groups** - Configurable worker node groups with multiple instance types
- **Cluster Logging** - Configurable CloudWatch log groups for EKS control plane
- **Add-on Version Management** - Automatic version management for EKS add-ons
- **Helm Deployment Support** - Automated deployment of critical cluster components
- **SSH Access Control** - Optional SSH access to worker nodes (disabled by default)
- **Comprehensive Tagging** - Resource tagging support for cost management and organization
- **Multiple VPC/Subnet Selection Methods** - Flexible configuration for different environments
- **Manifest Examples** - Sample Kubernetes manifests with DNS integration
- **Task Automation** - Complete Taskfile for development and testing workflows

### Features
- **Three VPC Discovery Methods**: By name tag, custom tags, or explicit VPC ID
- **Automatic Subnet Selection**: Uses kubernetes.io/role/internal-elb tags by default
- **Security-First Design**: API server access restrictions, no SSH by default
- **Production-Ready**: Comprehensive logging, monitoring, and security configurations
- **Multi-Environment Support**: Parameterized configuration for different environments
- **Documentation**: Complete setup guides and usage examples

### Technical Details
- **Terraform Version**: >= 1.0
- **AWS Provider**: >= 5.0
- **Kubernetes Provider**: >= 2.20
- **Helm Provider**: >= 2.10
- **EKS Version**: Supports 1.28+ (default: 1.32)
- **Node Groups**: Configurable instance types, sizes, and AMI types

### Module Structure
- Centralized module in `modules/eks/`
- Root-level complete deployment example
- Comprehensive variable definitions
- Detailed outputs for integration
- Separated IAM, Route53, and Helm configurations

[1.0.0]: https://github.com/aws-terraform-repos/aws-eks-module/releases/tag/v1.0.0