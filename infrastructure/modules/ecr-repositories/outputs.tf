output "repository_urls" {
  description = "URLs of the created ECR repositories"
  value = {
    for k, v in aws_ecr_repository.repositories : k => v.repository_url
  }
}

output "registry_id" {
  description = "Registry ID for ECR authentication"
  value       = values(aws_ecr_repository.repositories)[0].registry_id
}

output "repositories" {
  description = "ECR repository resources"
  value       = aws_ecr_repository.repositories
}

