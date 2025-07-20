# ECR Container Registry Infrastructure Plan

This document outlines the Terraform plan to create an AWS ECR Registry, build frontend and backend containers, and push them to ECR using the Kreuzwerker/Docker provider and AWS Provider.

## Overview

The solution will be implemented as a modular Terraform configuration that:

- Creates ECR repositories for frontend and backend applications
- Builds Docker images locally using the Docker provider
- Pushes images to ECR with proper tagging
- Uses a local tag value to force rebuilds when incremented
- Follows Terraform best practices with modular design

## Architecture Components

### 1. ECR Repositories Module (`modules/ecr-repositories`)
- Creates ECR repositories for frontend and backend
- Configures lifecycle policies for image cleanup
- Sets up repository policies for access control
- Outputs repository URLs and registry information

### 2. Container Build Module (`modules/container-build`)
- Builds Docker images using the Docker provider
- Tags images with build version and latest
- Pushes images to ECR repositories
- Handles authentication to ECR

### 3. Root Module
- Orchestrates the ECR and container build modules
- Defines local variables for versioning and configuration
- Manages provider configurations and versions

## File Structure

```
.
├── main.tf                    # Root module configuration
├── variables.tf               # Input variables
├── outputs.tf                 # Output values
├── locals.tf                  # Local values and build tags
├── providers.tf               # Provider configurations
├── terraform.tf               # Terraform and provider requirements
├── modules/
│   ├── ecr-repositories/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   └── container-build/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── README.md
└── ecr.md                     # This documentation
```

## Implementation Plan

### Phase 1: ECR Repository Module

**File: `modules/ecr-repositories/main.tf`**
```hcl
# ECR repositories for frontend and backend
resource "aws_ecr_repository" "repositories" {
  for_each = var.repositories
  
  name                 = each.key
  image_tag_mutability = "MUTABLE"
  
  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = merge(var.common_tags, {
    Name = each.key
    Type = each.value.type
  })
}

# Lifecycle policy to manage image retention
resource "aws_ecr_lifecycle_policy" "repositories" {
  for_each   = aws_ecr_repository.repositories
  repository = each.value.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v"]
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Delete untagged images older than 1 day"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 1
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
```

**File: `modules/ecr-repositories/variables.tf`**
```hcl
variable "repositories" {
  description = "Map of ECR repository configurations"
  type = map(object({
    type        = string
    description = string
  }))
  
  validation {
    condition = alltrue([
      for repo in values(var.repositories) : 
      contains(["frontend", "backend"], repo.type)
    ])
    error_message = "Repository type must be either 'frontend' or 'backend'."
  }
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "region" {
  description = "AWS region"
  type        = string
}
```

**File: `modules/ecr-repositories/outputs.tf`**
```hcl
output "repository_urls" {
  description = "URLs of the created ECR repositories"
  value = {
    for k, v in aws_ecr_repository.repositories : k =e v.repository_url
  }
}

output "registry_id" {
  description = "Registry ID for ECR authentication"
  value = values(aws_ecr_repository.repositories)[0].registry_id
}

output "repositories" {
  description = "ECR repository resources"
  value = aws_ecr_repository.repositories
}
```

### Phase 2: Container Build Module

**File: `modules/container-build/main.tf`**
```hcl
# Data source to get ECR authorization token
data "aws_ecr_authorization_token" "token" {}

# Local values for image tagging
locals {
  image_tag = "v${var.build_version}"
  
  # Build contexts for each application
  build_configs = {
    for app_name, config in var.applications : app_name =e {
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
    build_version = var.build_version
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
```

**File: `modules/container-build/variables.tf`**
```hcl
variable "applications" {
  description = "Application configurations for building containers"
  type = map(object({
    context    = string
    dockerfile = string
  }))
  
  validation {
    condition = alltrue([
      for app_name, config in var.applications :
      can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", app_name))
    ])
    error_message = "Application names must be lowercase alphanumeric with hyphens."
  }
}

variable "repository_urls" {
  description = "Map of ECR repository URLs"
  type        = map(string)
}

variable "build_version" {
  description = "Build version tag (increment to force rebuild)"
  type        = string
  
  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+$", var.build_version))
    error_message = "Build version must be in semantic version format (x.y.z)."
  }
}

variable "keep_locally" {
  description = "Whether to keep images locally after build"
  type        = bool
  default     = false
}

variable "keep_remotely" {
  description = "Whether to keep images in registry when destroyed"
  type        = bool
  default     = true
}
```

**File: `modules/container-build/outputs.tf`**
```hcl
output "image_ids" {
  description = "Docker image IDs that were built"
  value = {
    for k, v in docker_image.applications : k =e v.image_id
  }
}

output "image_tags" {
  description = "Image tags that were pushed"
  value = {
    for k, v in local.build_configs : k =e v.tags
  }
}

output "pushed_images" {
  description = "Registry images that were pushed"
  value = {
    for k, v in docker_registry_image.applications : k =e {
      name = v.name
      sha256_digest = v.sha256_digest
    }
  }
}
```

### Phase 3: Root Module Configuration

**File: `terraform.tf`**
```hcl
terraform {
  required_version = "e= 1.5"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~e 5.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "~e 3.0"
    }
  }
}
```

**File: `providers.tf`**
```hcl
provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = local.common_tags
  }
}

provider "docker" {
  # Configure Docker provider to use ECR registry
  registry_auth {
    address  = data.aws_ecr_authorization_token.token.proxy_endpoint
    username = data.aws_ecr_authorization_token.token.user_name
    password = data.aws_ecr_authorization_token.token.password
  }
}

# ECR authorization token for Docker provider
data "aws_ecr_authorization_token" "token" {}
```

**File: `locals.tf`**
```hcl
locals {
  # Build version - increment this to force rebuild
  build_version = "1.0.0"
  
  # Environment and project configuration
  project_name = "compliance-dash"
  environment  = var.environment
  
  # Common tags applied to all resources
  common_tags = {
    Project     = local.project_name
    Environment = local.environment
    ManagedBy   = "terraform"
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
      context    = "./frontend"
      dockerfile = "Dockerfile"
    }
    "${local.project_name}-backend" = {
      context    = "./backend"
      dockerfile = "Dockerfile"
    }
  }
}
```

**File: `main.tf`**
```hcl
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
```

**File: `variables.tf`**
```hcl
variable "aws_region" {
  description = "AWS region for ECR repositories"
  type        = string
  default     = "us-east-1"
  
  validation {
    condition = can(regex("^[a-z0-9-]+$", var.aws_region))
    error_message = "AWS region must be a valid region identifier."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}
```

**File: `outputs.tf`**
```hcl
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
```

## Usage Instructions

### 1. Initial Setup
```bash
# Initialize Terraform
terraform init

# Plan the infrastructure
terraform plan

# Apply the configuration
terraform apply
```

### 2. Forcing a Rebuild
To force a new build and push, increment the `build_version` in `locals.tf`:

```hcl
locals {
  # Increment this version to force rebuild
  build_version = "1.0.1"  # Changed from "1.0.0"
}
```

Then run:
```bash
terraform plan
terraform apply
```

### 3. Environment-specific Deployments
```bash
# Deploy to staging
terraform apply -var="environment=staging"

# Deploy to production
terraform apply -var="environment=prod"
```

## Key Features

### 1. **Modular Design**
- Separate modules for ECR repositories and container builds
- Reusable components that can be easily extended
- Clear separation of concerns

### 2. **Best Practices**
- Use `for_each` instead of `count` for resource iteration
- Proper variable validation and descriptions
- Comprehensive tagging strategy
- Version pinning for providers

### 3. **Build Management**
- Local build version tag for forced rebuilds
- Content-based triggers for automatic rebuilds on code changes
- Semantic versioning for image tags

### 4. **Security**
- ECR image scanning enabled
- Proper lifecycle policies for image cleanup
- Encrypted repositories

### 5. **Flexibility**
- Environment-specific configurations
- Configurable retention policies
- Support for additional applications through configuration

## Future Extensions

This modular design allows for easy extension:

1. **Additional Applications**: Add new applications by updating `local.applications`
2. **Multi-environment Support**: Create workspace-specific variable files
3. **Advanced Policies**: Add custom ECR repository policies
4. **Monitoring**: Integrate with CloudWatch for build monitoring
5. **CI/CD Integration**: Use with GitHub Actions or other CI/CD systems

## Prerequisites

- AWS CLI configured with appropriate permissions
- Docker installed and running
- Terraform e= 1.5
- ECR repository permissions for the AWS account

## Dependencies

The modules have the following dependencies:
- `ecr-repositories` → AWS ECR permissions
- `container-build` → Docker daemon, ECR repositories
- Root module → Both child modules

This plan provides a robust, scalable foundation for managing ECR repositories and container builds with Terraform, following all specified best practices and requirements.
