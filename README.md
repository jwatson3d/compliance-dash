# Compliance Dashboard

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Node.js Version](https://img.shields.io/badge/node-%3E%3D%2020.x-brightgreen)](https://nodejs.org/)
[![Terraform Version](https://img.shields.io/badge/terraform-%3E%3D%201.10-623ce4)](https://terraform.io/)
[![Docker](https://img.shields.io/badge/docker-%3E%3D%2020.x-0db7ed.svg)](https://www.docker.com/)

> A modern, containerized compliance management dashboard for monitoring and managing infrastructure compliance standards.

## Table of Contents

- [Overview](#overview)
- [Architecture & Stack](#architecture--stack)
- [Getting Started](#getting-started)
- [Development](#development)
- [Deployment](#deployment)
- [Configuration](#configuration)
- [Project Structure](#project-structure)
- [Contributing](#contributing)
- [Support](#support)

## Overview

A full-stack application for streamlined compliance monitoring and management across cloud infrastructure, providing real-time tracking, policy management, and automated reporting.

**Key Features:**

- 📊 Real-time compliance monitoring
- 🔒 Security-first design with vulnerability scanning
- 🚀 Cloud-native containerized architecture
- 🔄 CI/CD pipeline integration
- 💰 Infrastructure cost optimization

## Architecture

```mermaid
graph TB
    subgraph "Client"
        UI[React Frontend]
    end
    
    subgraph "Application Tier"
        API[Node.js/Express API]
        Auth[Authentication Service]
    end
    
    subgraph "Data Tier"
        DB[(Database)]
        Cache[(Redis Cache)]
    end
    
    subgraph "External Services"
        AWS[AWS Services]
        OpenAI[OpenAI API]
    end
    
    UI --> API
    API --> Auth
    API --> DB
    API --> Cache
    API --> AWS
    API --> OpenAI
```

## Technology Stack

| Layer | Technology | Version | Purpose |
|-------|------------|---------|----------|
| **Frontend** | React | 19.x | User Interface |
| | Material-UI | 7.x | Component Library |
| | TypeScript | 4.x | Type Safety |
| | Chart.js | 4.x | Data Visualization |
| **Backend** | Node.js | 20.x | Runtime Environment |
| | Express | 5.x | Web Framework |
| | Prisma | 6.x | Database ORM |
| | TypeScript | 5.x | Type Safety |
| **Infrastructure** | Terraform | 1.10+ | Infrastructure as Code |
| | Docker | 20.x+ | Containerization |
| | AWS ECR | - | Container Registry |
| **DevOps** | Make | - | Task Automation |
| | Infracost | 0.10+ | Cost Estimation |

## Prerequisites

Before you begin, ensure you have the following installed:

- **Node.js**: v20.x or later ([Download](https://nodejs.org/))
- **npm**: v9.x or later (comes with Node.js)
- **Docker**: v20.x or later ([Download](https://www.docker.com/get-started))
- **Docker Compose**: v2.x or later
- **Terraform**: v1.10 or later ([Download](https://terraform.io/downloads))
- **AWS CLI**: v2.x ([Installation Guide](https://aws.amazon.com/cli/))
- **Infracost**: v0.10.x ([Installation Guide](https://www.infracost.io/docs/))
- **Make**: Available on most Unix systems

## Quick Start
1. **Clone the repository:**
    ```bash
    git clone https://github.com/your-repo/compliance-dash.git
    cd compliance-dash
    ```

2. **Initialize the environment:**
    ```bash
    make install
    make tf-init
    ```

3. **Start development servers:**
    ```bash
    make dev
    ```
    Frontend is available on `http://localhost:3000` and backend on `http://localhost:4000`.

4. **Run tests:**
    ```bash
    make test
    ```

5. **Build and deploy:**
    ```bash
    make build
    make docker-up
    make deploy-dev
    ```

## Development

### Environment Setup

1. **Clone and setup:**

   ```bash
   git clone <repository-url>
   cd compliance-dash
   make install
   ```

2. **Configure environment variables:**

   ```bash
   # Backend configuration
   cp backend/.env.example backend/.env
   
   # Frontend configuration (if needed)
   cp frontend/.env.example frontend/.env
   ```

3. **Start development servers:**

   ```bash
   make dev  # Starts both frontend and backend
   ```

### Available Make Commands

The project uses Make for task automation. View all available commands:

```bash
make help
```

**Common development tasks:**

```bash
make install           # Install all dependencies
make dev              # Start development servers
make test             # Run all tests
make lint             # Run linting
make build            # Build applications
make clean            # Clean build artifacts
```

**Docker commands:**

```bash
make docker-build     # Build Docker images
make docker-up        # Start with Docker Compose
make docker-logs      # View container logs
make docker-down      # Stop containers
```

**Infrastructure commands:**

```bash
make tf-init          # Initialize Terraform
make tf-plan          # Preview infrastructure changes
make tf-apply         # Apply infrastructure changes
make tf-cost          # Estimate costs with Infracost
```

## Testing

### Running Tests

```bash
# Run all tests
make test

# Run frontend tests only
make test-frontend

# Run backend tests only
make test-backend

# Run with coverage
cd frontend && npm test -- --coverage
cd backend && npm test -- --coverage
```

### Test Structure

- **Frontend Tests**: Located in `frontend/src/**/__tests__/`
- **Backend Tests**: Located in `backend/src/**/*.test.ts`
- **Integration Tests**: Located in `tests/integration/`

## Deployment

### Local Development

```bash
make docker-up    # Start with Docker Compose
```

Services will be available at:
- Frontend: http://localhost:3000
- Backend API: http://localhost:4000

### Cloud Deployment

#### Prerequisites
1. Configure AWS CLI with appropriate credentials
2. Set up Terraform backend (S3 bucket for state)
3. Configure environment-specific variables

#### Deploy to Environments

```bash
# Development
make deploy-dev

# Staging
make deploy-staging

# Production (requires confirmation)
make deploy-prod
```

#### Infrastructure Cost Estimation

```bash
make tf-cost  # Get cost breakdown with Infracost
```

### Container Updates

To rebuild and deploy updated containers:

```bash
make rebuild-containers  # Increments version and rebuilds
```

## Configuration

### Environment Variables

#### Backend Configuration (`.env`)

```bash
# Database
DATABASE_URL="postgresql://username:password@localhost:5432/compliance_db"

# API Keys
OPENAI_API_KEY="your-openai-api-key"
AWS_ACCESS_KEY_ID="your-aws-access-key"
AWS_SECRET_ACCESS_KEY="your-aws-secret-key"

# Application
PORT=4000
NODE_ENV=development
JWT_SECRET="your-jwt-secret"
```

#### Frontend Configuration (`.env`)

```bash
REACT_APP_API_URL=http://localhost:4000
REACT_APP_ENVIRONMENT=development
```

### Infrastructure Configuration

Terraform variables can be configured in `infrastructure/terraform.tfvars`:

```hcl
aws_region = "us-east-1"
environment = "dev"
```

## API Documentation

### Base URL

- Development: `http://localhost:4000`
- Production: `https://api.compliance-dash.com`

### Authentication

All API requests require a valid JWT token in the Authorization header:

```
Authorization: Bearer <token>
```

### Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/auth/login` | User authentication |
| GET | `/auth/profile` | Get user profile |
| GET | `/compliance/status` | Get compliance status |
| GET | `/compliance/reports` | Generate compliance reports |
| GET | `/health` | Health check endpoint |

For detailed API documentation, visit `/api-docs` when running the development server.

## Project Structure

```
compliance-dash/
├── backend/                    # Node.js/Express backend
│   ├── src/                   # Source code
│   │   ├── routes/           # API routes
│   │   ├── services/         # Business logic
│   │   ├── models/           # Data models
│   │   └── utils/            # Utility functions
│   ├── tests/                # Backend tests
│   ├── Dockerfile            # Backend container config
│   └── package.json          # Backend dependencies
│
├── frontend/                   # React frontend
│   ├── src/                  # Source code
│   │   ├── components/       # React components
│   │   ├── pages/           # Page components
│   │   ├── services/        # API services
│   │   └── utils/           # Utility functions
│   ├── public/              # Static assets
│   ├── Dockerfile           # Frontend container config
│   └── package.json         # Frontend dependencies
│
├── infrastructure/             # Infrastructure as Code
│   ├── modules/             # Terraform modules
│   │   ├── ecr-repositories/
│   │   └── container-build/
│   ├── terraform.tf         # Terraform configuration
│   ├── variables.tf         # Input variables
│   └── outputs.tf          # Output values
│
├── docker-compose.yml         # Local development setup
├── Makefile                   # Task automation
├── .gitignore                # Git ignore rules
└── README.md                 # Project documentation
```

## Contributing

We welcome contributions! Please follow these guidelines:

### Development Workflow

1. **Fork the repository**
2. **Create a feature branch**

   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Make your changes**
4. **Run tests and linting**

   ```bash
   make test
   make lint
   ```
5. **Commit your changes**

   ```bash
   git commit -m "feat: add your feature description"
   ```
6. **Push to your fork**

   ```bash
   git push origin feature/your-feature-name
   ```
7. **Create a Pull Request**

### Code Standards

- **Frontend**: Follow React/TypeScript best practices
- **Backend**: Follow Node.js/Express conventions
- **Infrastructure**: Follow Terraform best practices
- **Testing**: Maintain >90% code coverage
- **Documentation**: Update README and inline comments

### Commit Messages

Use [Conventional Commits](https://www.conventionalcommits.org/) format:

- `feat:` for new features
- `fix:` for bug fixes
- `docs:` for documentation changes
- `test:` for testing changes
- `refactor:` for code refactoring
- `chore:` maintenance tasks, dependency updates, or configuration changes

## Troubleshooting

### Common Issues

#### Docker Issues

**Problem**: "Cannot connect to the Docker daemon"

```bash
# Solution: Start Docker service
sudo systemctl start docker  # Linux
# or restart Docker Desktop on macOS/Windows
```

**Problem**: Port already in use

```bash
# Solution: Check what's using the port
lsof -i :3000  # or :4000
# Kill the process or use different ports
```

#### Terraform Issues

**Problem**: "terraform command not found"

```bash
# Solution: Install Terraform or add to PATH
brew install terraform  # macOS
# or download from https://terraform.io/downloads
```

**Problem**: AWS credentials not configured

```bash
# Solution: Configure AWS CLI
aws configure
# or set environment variables
export AWS_ACCESS_KEY_ID=your-key
export AWS_SECRET_ACCESS_KEY=your-secret
```

#### Node.js Issues

**Problem**: Node version mismatch

```bash
# Solution: Use Node Version Manager
nvm use 20  # or the required version
```

**Problem**: npm install failures

```bash
# Solution: Clear npm cache and reinstall
npm cache clean --force
rm -rf node_modules package-lock.json
npm install
```

### Getting Help

1. Check the [Issues](https://github.com/your-repo/compliance-dash/issues) page
2. Search existing discussions
3. Create a new issue with:
   - Problem description
   - Steps to reproduce
   - Environment details
   - Error messages/logs

### Debug Mode

Enable debug logging:

```bash
# Backend
export DEBUG=compliance-dash:*

# Frontend
export REACT_APP_DEBUG=true

# Terraform
export TF_LOG=DEBUG
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

### Community
- 💬 [Discussions](https://github.com/your-repo/compliance-dash/discussions)
- 🐛 [Issue Tracker](https://github.com/your-repo/compliance-dash/issues)
- 📧 Email: [support@compliance-dash.com](mailto:support@compliance-dash.com)

### Professional Support

For enterprise support, consulting, or custom development:
- 🏢 [Contact Sales](mailto:sales@compliance-dash.com)
- 📅 [Schedule a Demo](https://calendly.com/compliance-dash/demo)

---

**Made with ❤️ by the Compliance Dashboard Team**

