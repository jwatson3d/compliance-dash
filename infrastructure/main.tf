# ECR Repositories Module
module "ecr_repositories" {
  source = "./modules/ecr-repositories"

  repositories = local.repositories
  common_tags  = local.common_tags
  region       = var.aws_region
}

# Container Build and Push Module
module "container_build" {
  source = "./modules/container-build"

  applications    = local.applications
  repository_urls = module.ecr_repositories.repository_urls
  build_version   = local.build_version

  depends_on = [module.ecr_repositories]
}
