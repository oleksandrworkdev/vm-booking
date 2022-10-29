output "api_url" {
  value       = module.eks.hostname
  description = "The url of the application."
}
