output "cluster_endpoint" {
  value       = try(aws_eks_cluster.this.endpoint, null)
}

output "cluster_certificate_authority_data" {
  value       = try(aws_eks_cluster.this.certificate_authority[0].data, null)
}

output "node_role" {
  value = aws_iam_role.cluster.id
}
