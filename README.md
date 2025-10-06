# AWS EKS Terraform Module

This Terraform module creates an Amazon EKS (Elastic Kubernetes Service) cluster with managed node groups and essential add-ons.

## Features

- EKS Cluster with configurable Kubernetes version
- Managed Node Groups with auto-scaling
- Essential EKS Add-ons (VPC CNI, CoreDNS, kube-proxy, EBS CSI driver)
- IAM Roles for Service Accounts (IRSA) support
- Security groups with proper ingress/egress rules
- CloudWatch logging for control plane
- Comprehensive outputs for integration
- Configurable endpoint access and CIDR restrictions

## Usage

The module supports three different approaches for VPC and subnet discovery:

### Option 1: VPC Discovery by Name (Recommended)
```hcl
module "eks" {
  source = "path/to/this/module"

  cluster_name    = "my-eks-cluster"
  cluster_version = "1.28"
  
  # Discover VPC by name tag
  vpc_name = "my-vpc"
  # Uses default subnet_tags to find subnets with kubernetes.io/role/internal-elb = "1"
  
  node_group_instance_types = ["t3.medium"]
  node_group_desired_size   = 2
  node_group_max_size       = 4
  node_group_min_size       = 1
  
  # Optional configurations
  endpoint_private_access = true
  endpoint_public_access  = true
  public_access_cidrs    = ["10.0.0.0/16"]
  
  node_group_capacity_type = "ON_DEMAND"
  node_group_ami_type     = "AL2_x86_64"
  node_group_disk_size    = 20
  
  enable_irsa = true
  
  tags = {
    Environment = "production"
    Project     = "my-project"
  }
}
```

### Option 2: VPC and Subnet Discovery by Tags
```hcl
module "eks" {
  source = "path/to/this/module"

  cluster_name    = "my-eks-cluster"
  cluster_version = "1.28"
  
  # Discover VPC by tags
  vpc_tags = {
    Environment = "production"
    Team        = "platform"
  }
  
  # Discover subnets by custom tags
  subnet_tags = {
    Type        = "private"
    Environment = "production"
  }
  
  node_group_instance_types = ["t3.medium"]
  node_group_desired_size   = 2
  node_group_max_size       = 4
  node_group_min_size       = 1
  
  tags = {
    Environment = "production"
    Project     = "my-project"
  }
}
```

### Option 3: Explicit VPC and Subnet IDs (Backward Compatibility)
```hcl
module "eks" {
  source = "path/to/this/module"

  cluster_name    = "my-eks-cluster"
  cluster_version = "1.28"
  
  # Explicit VPC and subnet IDs
  vpc_id     = "vpc-12345678"
  subnet_ids = ["subnet-12345678", "subnet-87654321"]

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | ~> 5.0 |
| tls | ~> 4.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster_name | Name of the EKS cluster | `string` | n/a | yes |
| vpc_name | Name tag of the VPC where the cluster will be created | `string` | `null` | no |
| vpc_tags | Tags to identify the VPC where the cluster will be created | `map(string)` | `{}` | no |
| vpc_id | (Optional) Explicit VPC ID where the cluster will be created. If not provided, VPC will be discovered using vpc_name or vpc_tags | `string` | `null` | no |
| subnet_tags | Tags to identify subnets for the EKS cluster. If not provided, will use all private subnets in the VPC | `map(string)` | `{"kubernetes.io/role/internal-elb" = "1"}` | no |
| subnet_ids | (Optional) Explicit list of subnet IDs for the EKS cluster. If not provided, subnets will be discovered using subnet_tags | `list(string)` | `null` | no |
| cluster_version | Kubernetes version to use for the EKS cluster | `string` | `"1.28"` | no |
| node_group_instance_types | Instance types for the EKS node group | `list(string)` | `["t3.medium"]` | no |
| node_group_desired_size | Desired number of nodes in the node group | `number` | `2` | no |
| node_group_max_size | Maximum number of nodes in the node group | `number` | `4` | no |
| node_group_min_size | Minimum number of nodes in the node group | `number` | `1` | no |
| endpoint_private_access | Enable private API server endpoint | `bool` | `true` | no |
| endpoint_public_access | Enable public API server endpoint | `bool` | `true` | no |
| public_access_cidrs | List of CIDR blocks that can access the public API server endpoint | `list(string)` | `["0.0.0.0/0"]` | no |
| node_group_ami_type | Type of Amazon Machine Image (AMI) associated with the EKS Node Group | `string` | `"AL2_x86_64"` | no |
| node_group_capacity_type | Type of capacity associated with the EKS Node Group. Valid values: ON_DEMAND, SPOT | `string` | `"ON_DEMAND"` | no |
| node_group_disk_size | Disk size in GiB for worker nodes | `number` | `20` | no |
| enable_irsa | Enable IAM Roles for Service Accounts | `bool` | `true` | no |
| tags | A map of tags to add to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_endpoint | Endpoint for EKS control plane |
| cluster_name | EKS cluster name |
| cluster_certificate_authority_data | Base64 encoded certificate data required to communicate with the cluster |
| cluster_arn | EKS cluster ARN |
| cluster_oidc_issuer_url | The URL on the EKS cluster for the OpenID Connect identity provider |
| oidc_provider_arn | The ARN of the OIDC Provider if IRSA is enabled |
| ebs_csi_driver_role_arn | ARN of the EBS CSI driver IAM role |
| node_security_group_id | ID of the node shared security group |
| cluster_security_group_id | Security group ID attached to the cluster control plane |

## Post-Deployment

After deployment, configure kubectl:

```bash
aws eks update-kubeconfig --region <region> --name <cluster-name>
```

## Security Considerations

- The module creates security groups with appropriate ingress/egress rules
- API server access can be restricted using `public_access_cidrs`
- Private endpoint access is enabled by default
- IRSA (IAM Roles for Service Accounts) is enabled by default for secure pod-to-AWS service communication

## Examples

See the `eks-terraform/` directory for a complete example that includes VPC creation.

## License

MIT
