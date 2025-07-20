# Compliance Dashboard Makefile
# Supports Docker, Terraform, and Node.js operations

# Variables
PROJECT_NAME := compliance-dash
BACKEND_DIR := backend
FRONTEND_DIR := frontend
INFRA_DIR := infrastructure
DOCKER_COMPOSE_FILE := docker-compose.yml

# Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[0;33m
BLUE := \033[0;34m
NC := \033[0m # No Color

# Default target
.PHONY: help
help: ## Show this help message
	@echo "$(BLUE)Compliance Dashboard - Makefile Help$(NC)"
	@echo "======================================="
	@awk 'BEGIN {FS = ":.*##"; printf "\n$(GREEN)Usage:$(NC)\n  make $(YELLOW)<target>$(NC)\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  $(YELLOW)%-25s$(NC) %s\n", $$1, $$2 } /^##@/ { printf "\n$(BLUE)%s$(NC)\n", substr($$0, 5) }' $(MAKEFILE_LIST)

##@ Development Commands
.PHONY: install
install: ## Install all dependencies (frontend, backend)
	@echo "$(GREEN)Installing dependencies...$(NC)"
	@$(MAKE) install-frontend
	@$(MAKE) install-backend

.PHONY: install-frontend
install-frontend: ## Install frontend dependencies
	@echo "$(GREEN)Installing frontend dependencies...$(NC)"
	cd $(FRONTEND_DIR) && npm ci

.PHONY: install-backend
install-backend: ## Install backend dependencies
	@echo "$(GREEN)Installing backend dependencies...$(NC)"
	cd $(BACKEND_DIR) && npm ci

.PHONY: dev
dev: ## Start development servers (frontend and backend)
	@echo "$(GREEN)Starting development servers...$(NC)"
	@$(MAKE) -j2 dev-frontend dev-backend

.PHONY: dev-frontend
dev-frontend: ## Start frontend development server
	@echo "$(GREEN)Starting frontend development server...$(NC)"
	cd $(FRONTEND_DIR) && npm start

.PHONY: dev-backend
dev-backend: ## Start backend development server
	@echo "$(GREEN)Starting backend development server...$(NC)"
	cd $(BACKEND_DIR) && npm start

.PHONY: build
build: ## Build both frontend and backend
	@echo "$(GREEN)Building applications...$(NC)"
	@$(MAKE) build-frontend
	@$(MAKE) build-backend

.PHONY: build-frontend
build-frontend: ## Build frontend application
	@echo "$(GREEN)Building frontend...$(NC)"
	cd $(FRONTEND_DIR) && npm run build

.PHONY: build-backend
build-backend: ## Build backend application (if build script exists)
	@echo "$(GREEN)Building backend...$(NC)"
	cd $(BACKEND_DIR) && if npm run | grep -q "build"; then npm run build; else echo "No build script found"; fi

.PHONY: test
test: ## Run tests for both frontend and backend
	@echo "$(GREEN)Running tests...$(NC)"
	@$(MAKE) test-frontend
	@$(MAKE) test-backend

.PHONY: test-frontend
test-frontend: ## Run frontend tests
	@echo "$(GREEN)Running frontend tests...$(NC)"
	cd $(FRONTEND_DIR) && npm test -- --watchAll=false

.PHONY: test-backend
test-backend: ## Run backend tests
	@echo "$(GREEN)Running backend tests...$(NC)"
	cd $(BACKEND_DIR) && if npm run | grep -q "test"; then npm test; else echo "No test script found"; fi

.PHONY: lint
lint: ## Run linting for both frontend and backend
	@echo "$(GREEN)Running linting...$(NC)"
	@$(MAKE) lint-frontend
	@$(MAKE) lint-backend

.PHONY: lint-frontend
lint-frontend: ## Run frontend linting
	@echo "$(GREEN)Running frontend linting...$(NC)"
	cd $(FRONTEND_DIR) && if npm run | grep -q "lint"; then npm run lint; else echo "No lint script found"; fi

.PHONY: lint-backend
lint-backend: ## Run backend linting
	@echo "$(GREEN)Running backend linting...$(NC)"
	cd $(BACKEND_DIR) && if npm run | grep -q "lint"; then npm run lint; else echo "No lint script found"; fi

.PHONY: clean
clean: ## Clean all build artifacts and dependencies
	@echo "$(GREEN)Cleaning project...$(NC)"
	@$(MAKE) clean-frontend
	@$(MAKE) clean-backend
	@$(MAKE) clean-docker

.PHONY: clean-frontend
clean-frontend: ## Clean frontend build artifacts and dependencies
	@echo "$(GREEN)Cleaning frontend...$(NC)"
	cd $(FRONTEND_DIR) && rm -rf node_modules build dist
	cd $(FRONTEND_DIR) && if [ -f package-lock.json ]; then rm package-lock.json; fi

.PHONY: clean-backend
clean-backend: ## Clean backend build artifacts and dependencies
	@echo "$(GREEN)Cleaning backend...$(NC)"
	cd $(BACKEND_DIR) && rm -rf node_modules build dist
	cd $(BACKEND_DIR) && if [ -f package-lock.json ]; then rm package-lock.json; fi

##@ Docker Commands
.PHONY: docker-build
docker-build: ## Build Docker images for frontend and backend
	@echo "$(GREEN)Building Docker images...$(NC)"
	docker build -t $(PROJECT_NAME)-frontend:latest $(FRONTEND_DIR)
	docker build -t $(PROJECT_NAME)-backend:latest $(BACKEND_DIR)

.PHONY: docker-build-frontend
docker-build-frontend: ## Build frontend Docker image
	@echo "$(GREEN)Building frontend Docker image...$(NC)"
	docker build -t $(PROJECT_NAME)-frontend:latest $(FRONTEND_DIR)

.PHONY: docker-build-backend
docker-build-backend: ## Build backend Docker image
	@echo "$(GREEN)Building backend Docker image...$(NC)"
	docker build -t $(PROJECT_NAME)-backend:latest $(BACKEND_DIR)

.PHONY: docker-up
docker-up: ## Start services with Docker Compose
	@echo "$(GREEN)Starting Docker Compose services...$(NC)"
	docker-compose up -d

.PHONY: docker-down
docker-down: ## Stop Docker Compose services
	@echo "$(GREEN)Stopping Docker Compose services...$(NC)"
	docker-compose down

.PHONY: docker-logs
docker-logs: ## Show Docker Compose logs
	@echo "$(GREEN)Showing Docker Compose logs...$(NC)"
	docker-compose logs -f

.PHONY: docker-logs-backend
docker-logs-backend: ## Show backend container logs
	@echo "$(GREEN)Showing backend logs...$(NC)"
	docker-compose logs -f $(PROJECT_NAME)-backend

.PHONY: docker-logs-frontend
docker-logs-frontend: ## Show frontend container logs
	@echo "$(GREEN)Showing frontend logs...$(NC)"
	docker-compose logs -f $(PROJECT_NAME)-frontend

.PHONY: docker-ps
docker-ps: ## Show running Docker containers
	@echo "$(GREEN)Docker containers status:$(NC)"
	docker-compose ps

.PHONY: docker-restart
docker-restart: ## Restart Docker Compose services
	@echo "$(GREEN)Restarting Docker Compose services...$(NC)"
	docker-compose restart

.PHONY: docker-rebuild
docker-rebuild: ## Rebuild and restart Docker services
	@echo "$(GREEN)Rebuilding and restarting Docker services...$(NC)"
	docker-compose down
	docker-compose build --no-cache
	docker-compose up -d

.PHONY: clean-docker
clean-docker: ## Clean Docker images, containers, and volumes
	@echo "$(GREEN)Cleaning Docker resources...$(NC)"
	docker-compose down -v --remove-orphans
	docker image prune -f
	docker container prune -f
	docker volume prune -f

##@ Infrastructure Commands
.PHONY: tf-init
tf-init: ## Initialize Terraform
	@echo "$(GREEN)Initializing Terraform...$(NC)"
	cd $(INFRA_DIR) && terraform init

.PHONY: tf-plan
tf-plan: ## Run Terraform plan
	@echo "$(GREEN)Running Terraform plan...$(NC)"
	cd $(INFRA_DIR) && terraform plan

.PHONY: tf-apply
tf-apply: ## Apply Terraform configuration
	@echo "$(GREEN)Applying Terraform configuration...$(NC)"
	cd $(INFRA_DIR) && terraform apply

.PHONY: tf-destroy
tf-destroy: ## Destroy Terraform infrastructure
	@echo "$(RED)Destroying Terraform infrastructure...$(NC)"
	cd $(INFRA_DIR) && terraform destroy

.PHONY: tf-validate
tf-validate: ## Validate Terraform configuration
	@echo "$(GREEN)Validating Terraform configuration...$(NC)"
	cd $(INFRA_DIR) && terraform validate

.PHONY: tf-format
tf-format: ## Format Terraform files
	@echo "$(GREEN)Formatting Terraform files...$(NC)"
	cd $(INFRA_DIR) && terraform fmt -recursive

.PHONY: tf-format-check
tf-format-check: ## Check Terraform file formatting
	@echo "$(GREEN)Checking Terraform file formatting...$(NC)"
	cd $(INFRA_DIR) && terraform fmt -check=true -diff=true -recursive

.PHONY: tf-providers
tf-providers: ## Show Terraform providers
	@echo "$(GREEN)Showing Terraform providers...$(NC)"
	cd $(INFRA_DIR) && terraform providers

.PHONY: tf-output
tf-output: ## Show Terraform outputs
	@echo "$(GREEN)Showing Terraform outputs...$(NC)"
	cd $(INFRA_DIR) && terraform output

.PHONY: tf-state
tf-state: ## Show Terraform state
	@echo "$(GREEN)Showing Terraform state...$(NC)"
	cd $(INFRA_DIR) && terraform state list

.PHONY: tf-cost
tf-cost: ## Estimate infrastructure costs with Infracost
	@echo "$(GREEN)Estimating infrastructure costs...$(NC)"
	cd $(INFRA_DIR) && infracost breakdown --path .

.PHONY: tf-upgrade
tf-upgrade: ## Upgrade Terraform providers
	@echo "$(GREEN)Upgrading Terraform providers...$(NC)"
	cd $(INFRA_DIR) && terraform init -upgrade

.PHONY: tf-clean
tf-clean: ## Clean Terraform working directory
	@echo "$(GREEN)Cleaning Terraform working directory...$(NC)"
	cd $(INFRA_DIR) && rm -rf .terraform .terraform.lock.hcl

##@ Deployment Commands
.PHONY: deploy-dev
deploy-dev: ## Deploy to development environment
	@echo "$(GREEN)Deploying to development environment...$(NC)"
	cd $(INFRA_DIR) && terraform apply -var="environment=dev"

.PHONY: deploy-staging
deploy-staging: ## Deploy to staging environment
	@echo "$(GREEN)Deploying to staging environment...$(NC)"
	cd $(INFRA_DIR) && terraform apply -var="environment=staging"

.PHONY: deploy-prod
deploy-prod: ## Deploy to production environment
	@echo "$(RED)Deploying to production environment...$(NC)"
	@read -p "Are you sure you want to deploy to production? (y/N): " confirm && [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ] || (echo "Deployment cancelled" && exit 1)
	cd $(INFRA_DIR) && terraform apply -var="environment=prod"

.PHONY: increment-version
increment-version: ## Increment build version in locals.tf
	@echo "$(GREEN)Incrementing build version...$(NC)"
	cd $(INFRA_DIR) && \
	current_version=$$(grep 'build_version.*=' locals.tf | sed 's/.*"\([0-9]*\.[0-9]*\.[0-9]*\)".*/\1/'); \
	IFS='.' read -r major minor patch <<< "$$current_version"; \
	new_patch=$$((patch + 1)); \
	new_version="$$major.$$minor.$$new_patch"; \
	sed -i.bak "s/build_version.*=.*/build_version = \"$$new_version\"/" locals.tf && \
	rm locals.tf.bak && \
	echo "Version incremented from $$current_version to $$new_version"

.PHONY: rebuild-containers
rebuild-containers: ## Increment version and rebuild containers
	@echo "$(GREEN)Rebuilding containers with new version...$(NC)"
	@$(MAKE) increment-version
	cd $(INFRA_DIR) && terraform apply -auto-approve

##@ Quality Assurance
.PHONY: security-check
security-check: ## Run security checks
	@echo "$(GREEN)Running security checks...$(NC)"
	@$(MAKE) security-check-frontend
	@$(MAKE) security-check-backend

.PHONY: security-check-frontend
security-check-frontend: ## Run frontend security audit
	@echo "$(GREEN)Running frontend security audit...$(NC)"
	cd $(FRONTEND_DIR) && npm audit

.PHONY: security-check-backend
security-check-backend: ## Run backend security audit
	@echo "$(GREEN)Running backend security audit...$(NC)"
	cd $(BACKEND_DIR) && npm audit

.PHONY: update-deps
update-deps: ## Update dependencies for both frontend and backend
	@echo "$(GREEN)Updating dependencies...$(NC)"
	@$(MAKE) update-deps-frontend
	@$(MAKE) update-deps-backend

.PHONY: update-deps-frontend
update-deps-frontend: ## Update frontend dependencies
	@echo "$(GREEN)Updating frontend dependencies...$(NC)"
	cd $(FRONTEND_DIR) && npm update

.PHONY: update-deps-backend
update-deps-backend: ## Update backend dependencies
	@echo "$(GREEN)Updating backend dependencies...$(NC)"
	cd $(BACKEND_DIR) && npm update

##@ Utility Commands
.PHONY: status
status: ## Show project status
	@echo "$(BLUE)Project Status$(NC)"
	@echo "=============="
	@echo "$(YELLOW)Frontend:$(NC)"
	@if [ -d "$(FRONTEND_DIR)/node_modules" ]; then echo "  Dependencies: ✓ Installed"; else echo "  Dependencies: ✗ Not installed"; fi
	@if [ -f "$(FRONTEND_DIR)/build/index.html" ]; then echo "  Build: ✓ Built"; else echo "  Build: ✗ Not built"; fi
	@echo "$(YELLOW)Backend:$(NC)"
	@if [ -d "$(BACKEND_DIR)/node_modules" ]; then echo "  Dependencies: ✓ Installed"; else echo "  Dependencies: ✗ Not installed"; fi
	@echo "$(YELLOW)Infrastructure:$(NC)"
	@if [ -d "$(INFRA_DIR)/.terraform" ]; then echo "  Terraform: ✓ Initialized"; else echo "  Terraform: ✗ Not initialized"; fi
	@echo "$(YELLOW)Docker:$(NC)"
	@if docker-compose ps | grep -q "Up"; then echo "  Services: ✓ Running"; else echo "  Services: ✗ Not running"; fi

.PHONY: info
info: ## Show project information
	@echo "$(BLUE)Project Information$(NC)"
	@echo "==================="
	@echo "Project Name: $(PROJECT_NAME)"
	@echo "Backend Directory: $(BACKEND_DIR)"
	@echo "Frontend Directory: $(FRONTEND_DIR)"
	@echo "Infrastructure Directory: $(INFRA_DIR)"
	@echo ""
	@echo "$(YELLOW)Available Services:$(NC)"
	@echo "- Frontend: http://localhost:3000"
	@echo "- Backend: http://localhost:4000"
	@echo ""
	@echo "$(YELLOW)Quick Start:$(NC)"
	@echo "1. make install"
	@echo "2. make docker-up"
	@echo "3. make tf-init"

# Prevent make from interpreting files as targets
.DEFAULT_GOAL := help
%: 
	@:
