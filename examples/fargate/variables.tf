# Variables for Fargate EKS example

# AWS Region
variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "fargate-eks-cluster"
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
    Environment = "development"
    Project     = "fargate-example"
    ManagedBy   = "terraform"
    Owner       = "platform-team"
    ComputeType = "fargate-serverless"
  }
}

# Node Groups Variables (for system components)
variable "node_groups" {
  description = "Map of EKS managed node group definitions to create"
  type = map(object({
    desired_size   = number
    max_size       = number
    min_size       = number
    instance_types = list(string)
    capacity_type  = string
    labels         = optional(map(string), {})
    taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })), [])
  }))
  default = {}
}

# Fargate Profiles Variables
variable "fargate_profiles" {
  description = "Map of Fargate profile definitions to create"
  type = map(object({
    selectors = list(object({
      namespace = string
      labels    = optional(map(string), {})
    }))
  }))
  default = {}
}

# IRSA Variable
variable "enable_irsa" {
  description = "Whether to enable IAM Roles for Service Accounts (IRSA)"
  type        = bool
  default     = true
}

# Cluster Logging Variable
variable "cluster_log_types" {
  description = "List of control plane logging to enable"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}
