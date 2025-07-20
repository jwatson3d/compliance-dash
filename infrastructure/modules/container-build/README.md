# Container Build Module

This module builds Docker images and pushes them to ECR repositories using the Docker provider.

## Features

- Builds Docker images using local contexts and Dockerfiles
- Tags images with semantic version and latest tags
- Pushes images to ECR repositories
- Content-based triggers for automatic rebuilds
- Configurable image retention settings

## Usage

```hcl
module "container_build" {
  source = "./modules/container-build"
  
  applications = {
    "my-app-frontend" = {
      context    = "./frontend"
      dockerfile = "Dockerfile"
    }
    "my-app-backend" = {
      context    = "./backend"
      dockerfile = "Dockerfile"
    }
  }
  
  repository_urls = module.ecr_repositories.repository_urls
  build_version   = "1.0.0"
  
  keep_locally  = false
  keep_remotely = true
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| applications | Application configurations for building containers | `map(object)` | n/a | yes |
| repository_urls | Map of ECR repository URLs | `map(string)` | n/a | yes |
| build_version | Build version tag (increment to force rebuild) | `string` | n/a | yes |
| keep_locally | Whether to keep images locally after build | `bool` | `false` | no |
| keep_remotely | Whether to keep images in registry when destroyed | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| image_ids | Docker image IDs that were built |
| image_tags | Image tags that were pushed |
| pushed_images | Registry images that were pushed |

## Build Triggers

The module automatically rebuilds images when:
- The `build_version` variable changes
- The Dockerfile content changes
- Any file in the build context changes

## Image Tagging

Each image receives two tags:
- Semantic version tag (e.g., `v1.0.0`)
- Latest tag (`latest`)
