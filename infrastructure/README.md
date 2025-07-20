# Compliance Dashboard Infrastructure

This directory contains Terraform infrastructure code for deploying the Compliance Dashboard application to AWS, including ECR repositories and automated container builds.

## Architecture Overview

The infrastructure is organized into two main modules:

1. **ECR Repositories Module** (`modules/ecr-repositories/`)
   - Creates ECR repositories for frontend and backend containers
   - Configures image scanning and encryption
   - Sets up lifecycle policies for automated image cleanup

2. **Container Build Module** (`modules/container-build/`)
   - Builds Docker images using the Kreuzwerker/Docker provider
   - Pushes images to ECR with proper tagging
   - Handles content-based triggers for rebuilds

## Quick Start

### Prerequisites

- AWS CLI configured with appropriate permissions
- Docker installed and running
- Terraform >= 1.5

### Deployment

1. **Initialize Terraform:**
   ```bash
   cd infrastructure
   terraform init
   ```

2. **Review the plan:**
   ```bash
   terraform plan
   ```

3. **Deploy infrastructure:**
   ```bash
   terraform apply
   ```

### Force a Rebuild

To trigger a new container build, increment the `build_version` in `locals.tf`:

```hcl
locals {
  build_version = "1.0.1"  # Increment this value
}
```

Then apply the changes:
```bash
terraform apply
```

## Configuration

### Environment Variables

Set environment-specific configurations:

```bash
# Deploy to staging
terraform apply -var="environment=staging"

# Deploy to production  
terraform apply -var="environment=prod"
```

### Regional Deployment

Deploy to different AWS regions:

```bash
terraform apply -var="aws_region=us-west-2"
```

## File Structure

```
infrastructure/
├── main.tf                    # Root module configuration
├── variables.tf               # Input variables
├── outputs.tf                 # Output values
├── locals.tf                  # Local values and build versioning
├── providers.tf               # Provider configurations
├── terraform.tf               # Version requirements
├── README.md                  # This file
└── modules/
    ├── ecr-repositories/      # ECR repository management
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── README.md
    └── container-build/       # Docker image building and pushing
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf
        └── README.md
```

## Key Features

### 🏗️ **Modular Design**
- Separate, reusable modules for different concerns
- Clean interfaces between modules
- Easy to extend with additional functionality

### 🔒 **Security**
- ECR repositories encrypted at rest
- Image vulnerability scanning enabled
- Proper IAM roles and policies (when configured)

### 🔄 **Automated Builds**
- Content-based triggers rebuild on code changes
- Version-based rebuilds for controlled deployments
- Multi-tag strategy (semantic version + latest)

### 📊 **Lifecycle Management**
- Automatic cleanup of old images
- Configurable retention policies
- Cost optimization through image lifecycle

### 🌍 **Multi-Environment Support**
- Environment-specific configurations
- Regional deployment flexibility
- Consistent tagging strategy

## Outputs

After deployment, the following outputs are available:

- `ecr_repository_urls`: ECR repository URLs for pulling images
- `image_tags`: Tags of built and pushed images
- `build_version`: Current build version
- `registry_id`: ECR registry ID for authentication

## Troubleshooting

### Common Issues

1. **Docker daemon not running**: Ensure Docker is installed and running
2. **AWS permissions**: Verify AWS CLI is configured with ECR permissions
3. **Build context**: Check that Dockerfile paths are correct relative to contexts

### Debugging

Enable detailed logging:
```bash
export TF_LOG=DEBUG
terraform apply
```

View container build logs:
```bash
docker logs <container_id>
```

## Contributing

When making changes:

1. Update module documentation in respective README files
2. Validate configurations with `terraform validate`
3. Format code with `terraform fmt -recursive`
4. Test in development environment before production

## Security Considerations

- Store Terraform state in encrypted S3 backend (not included in this configuration)
- Use IAM roles with minimal required permissions
- Regularly update provider versions
- Monitor ECR repositories for vulnerabilities

## Cost Optimization

- Lifecycle policies automatically clean up old images
- Use appropriate ECR repository settings
- Monitor usage through AWS Cost Explorer
- Consider using ECR Public for open-source components
