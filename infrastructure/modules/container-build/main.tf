terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

# Data source to get ECR authorization token
data "aws_ecr_authorization_token" "token" {}

# Local values for image tagging
locals {
  image_tag = "v${var.build_version}"

  # Build contexts for each application
  build_configs = {
    for app_name, config in var.applications : app_name => {
      context    = config.context
      dockerfile = config.dockerfile
      repository = var.repository_urls[app_name]
      tags = [
        "${var.repository_urls[app_name]}:${local.image_tag}",
        "${var.repository_urls[app_name]}:latest"
      ]
    }
  }
}

# Build Docker images
resource "docker_image" "applications" {
  for_each = local.build_configs

  name = each.value.repository

  build {
    context    = each.value.context
    dockerfile = each.value.dockerfile

    tag = each.value.tags

    # Force rebuild when build_version changes
    build_args = {
      BUILD_VERSION = var.build_version
      BUILD_DATE    = timestamp()
    }
  }

  # Keep image locally after push
  keep_locally = var.keep_locally

  triggers = {
    build_version   = var.build_version
    dockerfile_hash = filesha256("${each.value.context}/${each.value.dockerfile}")
    context_hash = sha256(join("", [
      for f in fileset(each.value.context, "**") :
      filesha256("${each.value.context}/${f}")
    ]))
  }
}

# Push images to ECR
resource "docker_registry_image" "applications" {
  for_each = docker_image.applications

  name          = each.value.name
  keep_remotely = var.keep_remotely

  triggers = {
    image_id = each.value.image_id
  }

  depends_on = [docker_image.applications]
}
