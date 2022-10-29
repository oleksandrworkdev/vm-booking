output "vpc_id" {
  value       = aws_vpc.main.id
  description = "The id of the VPC."
}

output "vpc_public_az" {
  value       = aws_subnet.public_az
  description = "The public subnets of the VPC."
}

output "vpc_private_az" {
  value       = aws_subnet.private_az
  description = "The private subnets of the VPC."
}

output "vpc_public_az_1" {
  value       = aws_subnet.public_az[0].id
  description = "The public subnets of the VPC."
}

output "vpc_public_az_2" {
  value       = aws_subnet.public_az[1].id
  description = "The public subnets of the VPC."
}

output "vpc_private_az_1" {
  value       = aws_subnet.private_az[0].id
  description = "The private subnets of the VPC."
}

output "vpc_private_az_2" {
  value       = aws_subnet.private_az[1].id
  description = "The private subnets of the VPC."
}

output "vpc_name" {
  value       = var.vpc_name
  description = "The name of the VPC."
}
