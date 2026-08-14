variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "advanced-eks-cluster"
}

variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster"
  type        = string
  default     = "1.32"
}

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

variable "create_hosted_zones" {
  description = "Whether to create Route53 hosted zones and enable ExternalDNS"
  type        = bool
  default     = false
}

variable "hosted_zone_domains" {
  description = "List of domain names to create hosted zones for"
  type        = list(string)
  default     = []
}

variable "environment" {
  description = "Deployment environment (e.g. dev, staging, production), merged into resource tags as Environment"
  type        = string
  default     = "staging"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default = {
    Example = "advanced"
  }
}
