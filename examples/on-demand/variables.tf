# Variables for On-Demand EKS example

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "on-demand-eks-cluster"
}

variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster"
  type        = string
  default     = "1.32"
}

# VPC Discovery Variables
variable "vpc_name" {
  description = "Name tag of the VPC where the cluster will be created"
  type        = string
  default     = "default"
}

variable "vpc_tags" {
  description = "Tags to identify the VPC where the cluster will be created"
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "(Optional) Explicit VPC ID where the cluster will be created"
  type        = string
  default     = null
}

variable "subnet_tags" {
  description = "Tags to identify subnets for the EKS cluster"
  type        = map(string)
  default     = {}
}

variable "subnet_ids" {
  description = "(Optional) Explicit list of subnet IDs for the EKS cluster"
  type        = list(string)
  default     = null
}

# Node Group Variables
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

variable "node_group_ami_type" {
  description = "Type of Amazon Machine Image (AMI) associated with the EKS Node Group"
  type        = string
  default     = "AL2023_x86_64_STANDARD"
}

variable "node_group_disk_size" {
  description = "Disk size in GiB for nodes"
  type        = number
  default     = 20
}

variable "public_access_cidrs" {
  description = "List of CIDR blocks that can access the public API server endpoint"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

# DNS Configuration Variables
variable "create_hosted_zones" {
  description = "Whether to create Route53 hosted zones"
  type        = bool
  default     = false
}

variable "hosted_zone_domains" {
  description = "List of domain names to create hosted zones for"
  type        = list(string)
  default     = []
}

variable "create_subdomain_zones" {
  description = "Whether to create subdomain hosted zones"
  type        = bool
  default     = false
}

variable "subdomain_zones" {
  description = "List of subdomain prefixes to create zones for"
  type        = list(string)
  default     = []
}

# Fluent Bit Variables
variable "enable_fluent_bit" {
  description = "Whether to enable Fluent Bit for log collection"
  type        = bool
  default     = true
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

# Load Balancer and DNS Variables
variable "enable_load_balancer_controller" {
  description = "Whether to enable AWS Load Balancer Controller"
  type        = bool
  default     = true
}

variable "enable_external_dns" {
  description = "Whether to enable ExternalDNS"
  type        = bool
  default     = true
}

variable "external_dns_source" {
  description = "Sources for ExternalDNS to monitor"
  type        = list(string)
  default     = ["ingress", "service"]
}

variable "external_dns_provider" {
  description = "DNS provider for ExternalDNS"
  type        = string
  default     = "aws"
}

variable "external_dns_log_level" {
  description = "Log level for ExternalDNS"
  type        = string
  default     = "info"
}



# Helm Deployment Variables
variable "enable_helm_deployments" {
  description = "Whether to deploy Helm charts (Load Balancer Controller, ExternalDNS)"
  type        = bool
  default     = true
}

variable "helm_timeout" {
  description = "Timeout for Helm deployments in seconds"
  type        = number
  default     = 600
}

variable "wait_for_ready" {
  description = "Wait for Helm deployments to be ready"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default = {
    Environment = "production"
    Project     = "on-demand-example"
    ManagedBy   = "terraform"
    Owner       = "platform-team"
  }
}
