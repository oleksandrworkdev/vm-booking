output "app_url" {
  value       = module.app_vm_booking.api_url
  description = "The url of the application."
}

output "cluster_name" {
  value = module.eks.cluster_name
}