output "ecr_repository_urls" {
  description = "URLs of created ECR repositories"
  value       = module.ecr_repositories.repository_urls
}

output "image_tags" {
  description = "Tags of built and pushed images"
  value       = module.container_build.image_tags
}

output "build_version" {
  description = "Current build version"
  value       = local.build_version
}

output "registry_id" {
  description = "ECR registry ID"
  value       = module.ecr_repositories.registry_id
}
