output "endpoint" {
  value = aws_eks_cluster.ekscluster.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.ekscluster.certificate_authority[0].data
}