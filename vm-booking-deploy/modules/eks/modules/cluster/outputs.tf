output "cluster_name" {
  value       = aws_eks_cluster.cluster.name
  description = "Cluster name"
}

output "cluster_endpoint" {
  value       = aws_eks_cluster.cluster.endpoint
  description = "Cluster endpoint"
}

output "cluster_ca" {
  value       = aws_eks_cluster.cluster.certificate_authority.0.data
  description = "Cluster ca"
}

output "cluster_sg_id" {
  value       = aws_eks_cluster.cluster.vpc_config[0].cluster_security_group_id
  description = "Cluster SG id"
}

output "cluster_oidc_provider_url" {
  value = aws_iam_openid_connect_provider.cluster_oidc_provider.url
}

output "cluster_oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.cluster_oidc_provider.arn
}

output "node_role_arn" {
  value = aws_iam_role.eks_node_role.arn
}
