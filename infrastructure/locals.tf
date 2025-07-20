locals {
  # Build version - increment this to force rebuild
  build_version = "1.0.0"

  # Environment and project configuration
  project_name = "compliance-dash"
  environment  = var.environment

  # Common tags applied to all resources
  common_tags = {
    Project      = local.project_name
    Environment  = local.environment
    ManagedBy    = "terraform"
    BuildVersion = local.build_version
  }

  # Repository configuration
  repositories = {
    "${local.project_name}-frontend" = {
      type        = "frontend"
      description = "React frontend for compliance dashboard"
    }
    "${local.project_name}-backend" = {
      type        = "backend"
      description = "Node.js backend for compliance dashboard"
    }
  }

  # Application build configurations
  applications = {
    "${local.project_name}-frontend" = {
      context    = "../frontend"
      dockerfile = "Dockerfile"
    }
    "${local.project_name}-backend" = {
      context    = "../backend"
      dockerfile = "Dockerfile"
    }
  }
}
