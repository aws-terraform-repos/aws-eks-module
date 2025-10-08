# Root-level variables for the EKS module example

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "test-eks-cluster"
}

variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster"
  type        = string
  default     = "1.32"
}

variable "vpc_name" {
  description = "Name tag of the VPC where the cluster will be created"
  type        = string
  default     = null
}

variable "vpc_tags" {
  description = "Tags to identify the VPC where the cluster will be created"
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "(Optional) Explicit VPC ID where the cluster will be created. If not provided, VPC will be discovered using vpc_name or vpc_tags"
  type        = string
  default     = null
}

variable "subnet_tags" {
  description = "Tags to identify subnets for the EKS cluster. If not provided, will use all private subnets in the VPC"
  type        = map(string)
  default     = {}
}

variable "subnet_ids" {
  description = "(Optional) Explicit list of subnet IDs for the EKS cluster. If not provided, subnets will be discovered using subnet_tags"
  type        = list(string)
  default     = null
}

variable "node_group_instance_types" {
  description = "Instance types for the EKS node group. Optimized for spot pricing and EKS compatibility. Will automatically validate EKS compatibility and query spot prices."
  type        = list(string)
  default     = ["t3.medium", "t3a.medium", "m5.large", "m5a.large"]

  validation {
    condition     = length(var.node_group_instance_types) > 0
    error_message = "At least one instance type must be specified for the node group."
  }
}

variable "node_group_desired_size" {
  description = "Desired number of nodes in the node group"
  type        = number
  default     = 2
}

variable "node_group_max_size" {
  description = "Maximum number of nodes in the node group"
  type        = number
  default     = 4
}

variable "node_group_min_size" {
  description = "Minimum number of nodes in the node group"
  type        = number
  default     = 1
}

variable "node_group_capacity_type" {
  description = "Type of capacity associated with the EKS Node Group. Valid values: ON_DEMAND, SPOT"
  type        = string
  default     = "ON_DEMAND"
}

variable "node_group_ami_type" {
  description = "Type of Amazon Machine Image (AMI) associated with the EKS Node Group. AL2023_x86_64_STANDARD is required for Kubernetes 1.32+"
  type        = string
  default     = "AL2023_x86_64_STANDARD"
}

variable "node_group_disk_size" {
  description = "Disk size in GiB for worker nodes"
  type        = number
  default     = 20
}

variable "endpoint_private_access" {
  description = "Enable private API server endpoint"
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Enable public API server endpoint"
  type        = bool
  default     = true
}

variable "public_access_cidrs" {
  description = "List of CIDR blocks that can access the public API server endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enable_cluster_log_types" {
  description = "List of control plane logging to enable"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "enable_irsa" {
  description = "Enable IAM Roles for Service Accounts"
  type        = bool
  default     = true
}

variable "enable_ssh_access" {
  description = "Enable SSH access to worker nodes"
  type        = bool
  default     = false
}

variable "ssh_access_cidrs" {
  description = "List of CIDR blocks that can SSH to worker nodes"
  type        = list(string)
  default     = []
}

variable "ssh_key_name" {
  description = "EC2 Key Pair name for SSH access to worker nodes"
  type        = string
  default     = null
}

variable "enable_addon_version_management" {
  description = "Enable version management for EKS add-ons"
  type        = bool
  default     = true
}

variable "external_dns_zone_ids" {
  description = "List of Route53 hosted zone IDs ExternalDNS can manage; if empty, permissions apply to all zones (less secure)"
  type        = list(string)
  default     = []
}

variable "external_dns_domain_filters" {
  description = "List of domain filters for ExternalDNS (e.g., example.com); empty means all domains"
  type        = list(string)
  default     = []
}

variable "external_dns_txt_owner_id" {
  description = "ExternalDNS TXT owner ID used for record ownership"
  type        = string
  default     = null
}

variable "external_dns_policy" {
  description = "ExternalDNS update policy (upsert-only or sync)"
  type        = string
  default     = "upsert-only"
}

# Route53 Hosted Zone Configuration
variable "create_hosted_zones" {
  description = "Whether to create Route53 hosted zones for external-dns"
  type        = bool
  default     = false
}

variable "hosted_zone_domains" {
  description = "List of domain names to create hosted zones for (e.g., ['example.com', 'app.example.com'])"
  type        = list(string)
  default     = []
}

variable "primary_domain" {
  description = "Primary domain for subdomain zone creation (e.g., 'example.com')"
  type        = string
  default     = null
}

variable "create_subdomain_zones" {
  description = "Whether to create subdomain hosted zones under the primary domain"
  type        = bool
  default     = false
}

variable "subdomain_zones" {
  description = "List of subdomain prefixes to create zones for (e.g., ['dev', 'staging', 'api'])"
  type        = list(string)
  default     = []
}

variable "parent_zone_id" {
  description = "Parent zone ID for creating NS records (if managing subdomains under external parent)"
  type        = string
  default     = null
}

variable "enable_load_balancer_controller" {
  description = "Whether to enable AWS Load Balancer Controller IRSA role and Helm deployment"
  type        = bool
  default     = true
}

variable "enable_external_dns" {
  description = "Whether to enable ExternalDNS IRSA role and Helm deployment"
  type        = bool
  default     = true
}

variable "external_dns_source" {
  description = "ExternalDNS source types (ingress, service, etc.)"
  type        = list(string)
  default     = ["ingress", "service"]
}

variable "external_dns_provider" {
  description = "ExternalDNS DNS provider"
  type        = string
  default     = "aws"
}

variable "external_dns_log_level" {
  description = "ExternalDNS log level"
  type        = string
  default     = "info"
}

# Helm Deployment Variables
variable "enable_helm_deployments" {
  description = "Whether to deploy AWS Load Balancer Controller and ExternalDNS via Helm"
  type        = bool
  default     = false
}

variable "helm_timeout" {
  description = "Timeout for Helm deployments in seconds"
  type        = number
  default     = 600
}

variable "wait_for_ready" {
  description = "Whether to wait for Helm deployments to be ready"
  type        = bool
  default     = true
}

# Spot Instance Optimization Variables
variable "enable_spot_price_optimization" {
  description = "Enable automatic spot price optimization and recommendations"
  type        = bool
  default     = true
}

variable "spot_max_price" {
  description = "Maximum price per hour you're willing to pay for spot instances. If null, uses on-demand price."
  type        = string
  default     = null
}

variable "spot_interruption_behavior" {
  description = "Indicates how to handle instances when spot price exceeds max price. Valid values: hibernate, stop, terminate"
  type        = string
  default     = "terminate"

  validation {
    condition     = contains(["hibernate", "stop", "terminate"], var.spot_interruption_behavior)
    error_message = "Spot interruption behavior must be one of: hibernate, stop, terminate."
  }
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default = {
    Environment = "test"
    Project     = "eks-module-test"
    ManagedBy   = "terraform"
    Owner       = "test-user"
  }
}
