output "cluster_name" {
  value = aws_eks_cluster.my_eks.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.my_eks.endpoint
}

output "cluster_arn" {
  value = aws_eks_cluster.my_eks.arn
}
