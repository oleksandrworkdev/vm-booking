output "db_endpoint" {
  value       = aws_db_instance.db.endpoint
  description = "The endpoint of the db."
  sensitive   = true
}

output "ssm_db_username" {
  value       = aws_ssm_parameter.db_username.name
  description = "The name of the ssm parameter."
}

output "db_username" {
  value       = aws_ssm_parameter.db_username.value
  description = "DB username"
  sensitive   = true
}

output "ssm_db_password" {
  value       = aws_ssm_parameter.db_password.name
  description = "The name of the ssm parameter."
}

output "db_password" {
  value       = aws_ssm_parameter.db_password.value
  description = "DB password"
  sensitive   = true
}

output "ssm_db_host" {
  value       = aws_ssm_parameter.db_host.name
  description = "The name of the ssm parameter."
}

output "db_host" {
  value       = aws_ssm_parameter.db_host.value
  description = "DB host"
  sensitive   = true
}
