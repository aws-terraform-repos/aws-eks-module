resource "aws_eks_cluster" "ekscluster" {
  name     = var.cluster_name
  enabled_cluster_log_types = ["api", "audit"]
  role_arn = aws_iam_role.example.arn
  vpc_config {
    subnet_ids = [aws_subnet.example1.id, aws_subnet.example2.id]
  }
  depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.example-AmazonEKSVPCResourceController,
  ]
}