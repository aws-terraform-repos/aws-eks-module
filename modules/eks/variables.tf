variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
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
  description = "Instance types for the EKS node group"
  type        = list(string)
  default     = ["t3.medium"]
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

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
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

variable "node_group_ami_type" {
  description = "Type of Amazon Machine Image (AMI) associated with the EKS Node Group. AL2023_x86_64_STANDARD is required for Kubernetes 1.33+"
  type        = string
  default     = "AL2023_x86_64_STANDARD"
}

variable "node_group_capacity_type" {
  description = "Type of capacity associated with the EKS Node Group. Valid values: ON_DEMAND, SPOT"
  type        = string
  default     = "ON_DEMAND"
}

variable "node_group_disk_size" {
  description = "Disk size in GiB for worker nodes"
  type        = number
  default     = 20
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

# Fargate Configuration Variables
variable "fargate_profiles" {
  description = "Map of Fargate profiles to create"
  type = map(object({
    selectors = list(object({
      namespace = string
      labels    = optional(map(string), {})
    }))
    subnet_ids = optional(list(string), null)
    tags       = optional(map(string), {})
  }))
  default = {}
}

variable "node_groups" {
  description = "Map of node groups to create"
  type = map(object({
    desired_size   = number
    max_size       = number
    min_size       = number
    instance_types = list(string)
    capacity_type  = optional(string, "ON_DEMAND")
    labels         = optional(map(string), {})
    taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })), [])
    tags = optional(map(string), {})
  }))
  default = {}
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
  description = "Whether to enable AWS Load Balancer Controller IRSA role"
  type        = bool
  default     = true
}

variable "load_balancer_controller_chart_version" {
  description = "Helm chart version for AWS Load Balancer Controller"
  type        = string
  default     = null
}

variable "enable_external_dns" {
  description = "Whether to enable ExternalDNS IRSA role"
  type        = bool
  default     = true
}

variable "external_dns_chart_version" {
  description = "Helm chart version for ExternalDNS"
  type        = string
  default     = null
}

# Fluent Bit Configuration
variable "enable_fluent_bit" {
  description = "Whether to enable Fluent Bit for log collection"
  type        = bool
  default     = true
}

variable "fluent_bit_chart_version" {
  description = "Helm chart version for Fluent Bit"
  type        = string
  default     = null
}

variable "fluent_bit_log_group_name" {
  description = "CloudWatch Log Group name for Fluent Bit logs"
  type        = string
  default     = null
}

variable "fluent_bit_log_retention_days" {
  description = "Number of days to retain Fluent Bit logs in CloudWatch"
  type        = number
  default     = 30
}

# Enhanced ExternalDNS configuration
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

  validation {
    condition     = var.helm_timeout >= 300 && var.helm_timeout <= 1800
    error_message = "Helm timeout must be between 300 (5 minutes) and 1800 (30 minutes) seconds."
  }
}

variable "wait_for_ready" {
  description = "Whether to wait for Helm deployments to be ready"
  type        = bool
  default     = true
}

variable "cluster_readiness_timeout" {
  description = "Time to wait for cluster and node groups to be ready before Helm deployments (e.g., '60s', '5m')"
  type        = string
  default     = "60s"

  validation {
    condition     = can(regex("^[0-9]+(s|m|h)$", var.cluster_readiness_timeout))
    error_message = "Cluster readiness timeout must be a valid duration string (e.g., '30s', '5m', '1h')."
  }
}

# Flux CD Configuration
variable "enable_flux_cd" {
  description = "Whether to enable Flux CD IRSA role and Helm deployment"
  type        = bool
  default     = false
}

variable "flux_cd_chart_version" {
  description = "Helm chart version for Flux CD"
  type        = string
  default     = null
}

variable "flux_cd_namespace" {
  description = "Kubernetes namespace for Flux CD"
  type        = string
  default     = "flux-system"
}

variable "flux_cd_git_repository_url" {
  description = "Git repository URL for Flux CD to monitor"
  type        = string
  default     = null
}

variable "flux_cd_git_repository_branch" {
  description = "Git repository branch for Flux CD to monitor"
  type        = string
  default     = "main"
}

variable "flux_cd_git_repository_path" {
  description = "Path within the Git repository for Flux CD to monitor"
  type        = string
  default     = "./"
}

variable "flux_cd_git_repository_interval" {
  description = "Interval for Flux CD to check the Git repository"
  type        = string
  default     = "1m"
}

variable "flux_cd_git_auth_secret_name" {
  description = "Name of the Kubernetes secret containing Git authentication details"
  type        = string
  default     = null
}

variable "flux_cd_image_automation" {
  description = "Whether to enable Flux CD image automation"
  type        = bool
  default     = false
}

variable "flux_cd_notification_providers" {
  description = "List of notification providers for Flux CD alerts"
  type        = list(string)
  default     = []
}
