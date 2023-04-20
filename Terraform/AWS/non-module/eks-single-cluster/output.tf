output "endpoint" {
  value       = aws_eks_cluster.eks_cluster.endpoint
  description = "The endpoint for your EKS Kubernetes API"
}
output "kubeconfig-certificate-authority-data" {
  value       = aws_eks_cluster.eks_cluster.certificate_authority[0].data
  description = "The base64 encoded certificate data required to communicate with your cluster."
}