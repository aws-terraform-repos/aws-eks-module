# AWS EKS Terraform Module with Route53 DNS Automation

## 📁 Repository Structure

This repository provides a production-ready EKS cluster with integrated Route53 hosted zones for automatic DNS management. The main EKS module is centralized in `modules/eks/` with the root configuration providing a complete DNS-enabled deployment.

```
aws-eks-module/
├── modules/eks/           # 🎯 Main EKS module (centralized)
│   ├── main.tf           # Core EKS resources
│   ├── variables.tf      # Module variables
│   ├── outputs.tf        # Module outputs
│   ├── iam.tf           # IAM roles and policies
│   ├── data.tf          # Data sources
│   ├── route53.tf       # Route53 hosted zones
│   ├── helm.tf          # Helm deployment guides
│   └── versions.tf      # Provider requirements
├── main.tf              # 🚀 Complete DNS-enabled EKS deployment
├── manifests/           # 🎨 Sample Kubernetes manifests with DNS
├── examples/            # 📖 Additional usage examples
├── README.md            # This file
├── TASKFILE.md          # Development workflow guide
└── Taskfile.yml         # Task automation
```

## 🚀 Quick Start - DNS-Enabled EKS Cluster

### 1. Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate permissions
- [Helm](https://helm.sh/docs/intro/install/) >= 3.0
- A registered domain name for Route53 hosted zone integration
- An existing VPC with subnets (or use the default VPC)

### 2. Deploy EKS with DNS Automation

1. **Clone and configure**:
   ```bash
   git clone <repository-url>
   cd aws-eks-module
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Edit terraform.tfvars** with your specific values:
   ```hcl
   cluster_name = "eks-dns-cluster"
   vpc_id = "vpc-your-vpc-id"  # or use vpc_name
   public_access_cidrs = ["YOUR.IP.ADDRESS/32"]  # Important for security!
   
   # Route53 DNS Configuration
   create_hosted_zones = true
   hosted_zone_domains = ["yourdomain.com"]  # Replace with your domain
   enable_external_dns = true
   enable_load_balancer_controller = true
   ```

3. **Deploy the infrastructure**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

4. **Follow post-deployment instructions**:
   ```bash
   terraform output deployment_instructions
   ```

The output will provide complete step-by-step instructions for:
- Configuring kubectl
- Installing ExternalDNS and AWS Load Balancer Controller via Helm
- Updating your domain's nameservers
- Deploying sample applications with automatic DNS

## 🎯 Key Features

- **🌍 Route53 Integration** - Automatic hosted zone creation and management
- **🔄 ExternalDNS** - Automatic DNS record management for ingresses and services
- **⚖️ Load Balancer Controller** - AWS ALB/NLB integration with Helm deployment
- **🔍 Smart VPC/Subnet Discovery** - Multiple discovery methods (name, tags, explicit IDs)
- **🔐 IRSA Support** - IAM Roles for Service Accounts enabled by default
- **🛡️ Security Groups** - Pre-configured with best practices
- **📦 EBS CSI Driver** - Auto-configured with proper IAM permissions
- **🌐 VPC CNI Enhancement** - Dedicated IRSA role for network security
- **📊 Add-on Management** - Automatic version management with conflict resolution
- **🔧 Flexible Configuration** - Three approaches for VPC/subnet selection

## 🌍 DNS Automation Workflow

1. **Deploy Infrastructure** → Creates EKS cluster + Route53 hosted zones + IAM roles
2. **Update Domain Registrar** → Point your domain to the provided name servers  
3. **Install Helm Charts** → ExternalDNS + AWS Load Balancer Controller
4. **Deploy Applications** → Ingress resources automatically get DNS records
5. **Automatic Management** → DNS records created/updated/deleted automatically

## 📋 Root Configuration Example

The root `main.tf` provides a complete DNS-enabled EKS deployment. Here's what it includes:

```hcl
# Complete EKS cluster with DNS automation
module "eks" {
  source = "./modules/eks"

  # Basic cluster configuration
  cluster_name    = "eks-dns-cluster"
  cluster_version = "1.33"
  vpc_id          = "vpc-your-vpc-id"

  # Route53 DNS automation
  create_hosted_zones    = true
  hosted_zone_domains    = ["yourdomain.com"]
  create_subdomain_zones = true
  subdomain_zones        = ["dev", "staging", "prod", "api"]

  # Enable DNS controllers
  enable_external_dns             = true
  enable_load_balancer_controller = true

  # Security configuration
  public_access_cidrs = ["your-ip/32"]
  enable_irsa = true

  tags = {
    Environment = "production"
    Project     = "dns-automation"
  }
}
```

### Using the Module in Other Projects

```hcl
module "eks" {
  source = "git::https://github.com/your-org/aws-eks-module.git//modules/eks"
  
  cluster_name = "my-eks-cluster"
  vpc_name     = "my-vpc"
  
  # Route53 Integration
  create_hosted_zones = true
  hosted_zone_domains = ["example.com"]
  
  # Override defaults as needed
  node_group_instance_types = ["t3.large"]
  public_access_cidrs       = ["203.0.113.0/32"]
  
  tags = {
    Environment = "production"
    Project     = "my-project"
  }
}
```

## 🎯 Key Features

- **🔍 Smart VPC/Subnet Discovery** - Multiple discovery methods
- **🔐 IRSA Support** - IAM Roles for Service Accounts enabled by default
- **🛡️ Security Groups** - Pre-configured with best practices
- **📦 EBS CSI Driver** - Auto-configured with proper IAM permissions
- **🌐 VPC CNI Enhancement** - Dedicated IRSA role for network security
- **📊 Add-on Management** - Automatic version management
- **🔧 Flexible Configuration** - Three approaches for VPC/subnet selection

## 📖 Usage Example

The root-level `main.tf` provides a complete working example:

### Option 1: VPC Discovery by Name (Recommended)
```hcl
module "eks" {
  source = "./modules/eks"

  cluster_name    = "my-eks-cluster"
  cluster_version = "1.33"
  
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
  node_group_ami_type     = "AL2023_x86_64_STANDARD"  # Required for K8s 1.33+
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
  cluster_version = "1.33"
  
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

After successful deployment, follow these steps to configure and validate your EKS cluster:

### 1. Configure kubectl
```bash
aws eks update-kubeconfig --region <region> --name <cluster-name>
```

### 2. Verify Cluster Access
```bash
kubectl get nodes
kubectl get pods -n kube-system
```

### 3. Validate Add-ons
```bash
# Check EKS add-ons status
aws eks describe-addon --cluster-name <cluster-name> --addon-name vpc-cni
aws eks describe-addon --cluster-name <cluster-name> --addon-name coredns
aws eks describe-addon --cluster-name <cluster-name> --addon-name kube-proxy
aws eks describe-addon --cluster-name <cluster-name> --addon-name aws-ebs-csi-driver
```

### 4. Test Storage (EBS CSI)
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-ebs-csi-driver/master/examples/kubernetes/dynamic-provisioning/manifests/storageclass.yaml
```

### 5. Verify IRSA (if enabled)
```bash
kubectl get serviceaccounts -n kube-system
kubectl describe serviceaccount ebs-csi-controller-sa -n kube-system
```

## Security Considerations

- The module creates security groups with appropriate ingress/egress rules
- API server access can be restricted using `public_access_cidrs`
- Private endpoint access is enabled by default
- IRSA (IAM Roles for Service Accounts) is enabled by default for secure pod-to-AWS service communication

## Examples

See the `examples/` directory for complete working examples:

- **[Simple Cluster](./examples/simple-cluster/)**: Minimal configuration for quick deployment
- **[VPC Name Discovery](./examples/vpc-name-discovery/)**: VPC discovery by name tag
- **[Tag-Based Discovery](./examples/tag-based-discovery/)**: VPC and subnet discovery by custom tags
- **[Explicit IDs](./examples/explicit-ids/)**: Explicit VPC and subnet IDs for maximum control

Each example includes:
- Complete Terraform configuration
- Detailed README with usage instructions
- Variable definitions and example values
- Expected outputs and validation steps

### Quick Testing with Taskfile

This repository includes a [Taskfile](./TASKFILE.md) for easy testing and validation:

```bash
# Install Task runner (one-time setup)
brew install go-task/tap/go-task

# Run complete test suite
task test-all

# Validate all examples
task validate-examples

# Plan specific example
task plan-simple-cluster
```

See [TASKFILE.md](./TASKFILE.md) for complete usage instructions.

## Security Best Practices

- **Restrict API Access**: Use `public_access_cidrs` to limit who can access the API server
- **Enable Private Endpoint**: Keep `endpoint_private_access = true` for internal cluster communication
- **IRSA**: Enable `enable_irsa = true` for secure pod-to-AWS service communication
- **Node SSH Access**: Only enable `enable_ssh_access = true` if absolutely necessary for debugging
- **Regular Updates**: Keep Kubernetes version and add-ons updated
- **Least Privilege**: Use specific IAM roles and policies for workloads

## Add-on Management

The module automatically manages EKS add-ons with the latest compatible versions:
- **VPC CNI**: Network plugin for pod networking with IRSA support
- **CoreDNS**: DNS server for service discovery
- **kube-proxy**: Network proxy for services
- **EBS CSI Driver**: Storage driver for persistent volumes with IRSA support

All add-ons support version management and can be configured independently.

## License

MIT
