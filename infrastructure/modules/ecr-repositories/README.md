# ECR Repositories Module

This module creates and manages AWS ECR repositories for containerized applications.

## Features

- Creates ECR repositories with encryption enabled
- Configures image scanning on push
- Sets up lifecycle policies for image retention
- Supports multiple repositories via `for_each`
- Applies consistent tagging strategy

## Usage

```hcl
module "ecr_repositories" {
  source = "./modules/ecr-repositories"
  
  repositories = {
    "my-app-frontend" = {
      type        = "frontend"
      description = "Frontend application repository"
    }
    "my-app-backend" = {
      type        = "backend"
      description = "Backend application repository"
    }
  }
  
  common_tags = {
    Project     = "my-project"
    Environment = "dev"
  }
  
  region = "us-east-1"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| repositories | Map of ECR repository configurations | `map(object)` | n/a | yes |
| common_tags | Common tags to apply to all resources | `map(string)` | `{}` | no |
| region | AWS region | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| repository_urls | URLs of the created ECR repositories |
| registry_id | Registry ID for ECR authentication |
| repositories | ECR repository resources |

## Lifecycle Policy

The module automatically creates lifecycle policies for each repository:
- Keeps the last 10 tagged images (with "v" prefix)
- Deletes untagged images older than 1 day
