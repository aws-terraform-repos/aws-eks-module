# Variables for Flux CD EKS example

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "flux-cd-eks-cluster"
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

variable "public_access_cidrs" {
  description = "List of CIDR blocks that can access the public API server endpoint"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "enable_flux_cd" {
  description = "Whether to enable Flux CD"
  type        = bool
  default     = true
}

variable "flux_cd_git_repository_url" {
  description = "Git repository URL for Flux CD to monitor"
  type        = string
  default     = "https://github.com/your-org/k8s-manifests"
}

variable "flux_cd_git_repository_branch" {
  description = "Git repository branch for Flux CD to monitor"
  type        = string
  default     = "main"
}

variable "flux_cd_git_repository_path" {
  description = "Path within the Git repository for Flux CD to monitor"
  type        = string
  default     = "./clusters/flux-cd-eks-cluster"
}

variable "flux_cd_git_auth_secret_name" {
  description = "Name of the Kubernetes secret containing Git authentication details"
  type        = string
  default     = null
}

variable "flux_cd_image_automation" {
  description = "Whether to enable Flux CD image automation"
  type        = bool
  default     = true
}

variable "enable_helm_deployments" {
  description = "Whether to deploy Helm charts"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default = {
    Environment = "development"
    Project     = "flux-cd-example"
    ManagedBy   = "terraform"
    Owner       = "platform-team"
  }
}
