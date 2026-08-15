# Configure kubectl Provider (required by the module's Flux CD manifests)
#
# lazy_load defers building the client until first use instead of validating
# host/cert at provider-configure time, since those come from module.eks
# outputs that are unknown until the cluster is created.
provider "kubectl" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  load_config_file       = false
  lazy_load              = true
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}
