output "cluster_name" {
  value       = module.cluster.cluster_name
  description = "Cluster name"
}

output "cluster_endpoint" {
  value       = module.cluster.cluster_endpoint
  description = "Cluster endpoint"
}

output "cluster_ca" {
  value       = module.cluster.cluster_ca
  description = "Cluster ca"
}

output "cluster_sg_id" {
  value       = module.cluster.cluster_sg_id
  description = "Cluster SG id"
}
