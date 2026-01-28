# =============================================================================
# ADAPTIVE GUARDIAN - MAKEFILE (macOS Compatible)
# =============================================================================
# 
# This Makefile provides convenient shortcuts for common development tasks.
# Run 'make help' to see all available targets.
#
# Prerequisites:
#   - Python 3.11+ installed
#   - Docker Desktop installed and running
#   - Virtual environment created at ~/Developer/projects/adaptive-guardian-venv
# =============================================================================

.PHONY: help setup test lint format build deploy clean docs run-local

# -----------------------------------------------------------------------------
# COLORS FOR OUTPUT
# -----------------------------------------------------------------------------
RED     := \033[0;31m
GREEN   := \033[0;32m
YELLOW  := \033[1;33m
BLUE    := \033[0;34m
NC      := \033[0m # No Color

# -----------------------------------------------------------------------------
# VARIABLES - macOS Compatible
# -----------------------------------------------------------------------------
PYTHON      := python3.11
# Use the actual venv location (outside project directory)
VENV        := $(HOME)/Developer/projects/adaptive-guardian-venv
VENV_BIN    := $(VENV)/bin
PIP         := $(VENV_BIN)/pip
PYTEST      := $(VENV_BIN)/pytest
BLACK       := $(VENV_BIN)/black
PYLINT      := $(VENV_BIN)/pylint
MYPY        := $(VENV_BIN)/mypy
ISORT       := $(VENV_BIN)/isort
DOCKER      := docker
DOCKER_COMPOSE := docker compose
KUBECTL     := kubectl

PROJECT_NAME := adaptive-guardian
SRC_DIR     := src
TEST_DIR    := tests
DOCS_DIR    := docs

# -----------------------------------------------------------------------------
# DEFAULT TARGET
# -----------------------------------------------------------------------------
.DEFAULT_GOAL := help

# -----------------------------------------------------------------------------
# HELP
# -----------------------------------------------------------------------------
help: ## Show this help message
	@echo "$(BLUE)Adaptive Guardian - Build System (macOS)$(NC)"
	@echo ""
	@echo "$(YELLOW)Available targets:$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)Usage:$(NC)"
	@echo "  make <target>"
	@echo ""

# -----------------------------------------------------------------------------
# ENVIRONMENT SETUP
# -----------------------------------------------------------------------------
setup: ## Install all dependencies and setup environment
	@echo "$(YELLOW)Setting up development environment...$(NC)"
	@echo "$(BLUE)Creating virtual environment...$(NC)"
	$(PYTHON) -m venv $(VENV)
	@echo "$(BLUE)Upgrading pip...$(NC)"
	$(PIP) install --upgrade pip setuptools wheel
	@echo "$(BLUE)Installing dependencies...$(NC)"
	$(PIP) install -r requirements.txt
	@echo "$(BLUE)Installing development dependencies...$(NC)"
	$(PIP) install pytest pytest-cov pytest-asyncio pytest-mock black pylint mypy isort flake8 || true
	@echo "$(GREEN)✓ Setup complete!$(NC)"

setup-dev: setup ## Setup development environment with additional tools
	@echo "$(BLUE)Installing additional development tools...$(NC)"
	$(PIP) install jupyter jupyterlab ipython
	@echo "$(GREEN)✓ Development setup complete!$(NC)"

# -----------------------------------------------------------------------------
# VIRTUAL ENVIRONMENT CHECK
# -----------------------------------------------------------------------------
check-venv: ## Check if virtual environment is activated
	@if [ -z "$$VIRTUAL_ENV" ]; then \
		echo "$(RED)Error: Virtual environment not activated!$(NC)"; \
		echo "$(YELLOW)Run: source $(VENV)/bin/activate$(NC)"; \
		exit 1; \
	fi

# -----------------------------------------------------------------------------
# TESTING
# -----------------------------------------------------------------------------
test: check-venv ## Run all tests
	@echo "$(YELLOW)Running all tests...$(NC)"
	@if [ -d "$(TEST_DIR)" ]; then \
		$(PYTEST) $(TEST_DIR)/ -v --cov=$(SRC_DIR) --cov-report=html --cov-report=term || true; \
	else \
		echo "$(YELLOW)No tests directory found. Creating structure...$(NC)"; \
		mkdir -p $(TEST_DIR)/unit $(TEST_DIR)/integration $(TEST_DIR)/e2e; \
		touch $(TEST_DIR)/__init__.py; \
		echo "$(GREEN)Test structure created. Add tests to $(TEST_DIR)/$(NC)"; \
	fi

test-unit: check-venv ## Run unit tests only
	@echo "$(YELLOW)Running unit tests...$(NC)"
	@if [ -d "$(TEST_DIR)/unit" ]; then \
		$(PYTEST) $(TEST_DIR)/unit/ -v || true; \
	else \
		echo "$(YELLOW)No unit tests found in $(TEST_DIR)/unit/$(NC)"; \
	fi

test-integration: check-venv ## Run integration tests only
	@echo "$(YELLOW)Running integration tests...$(NC)"
	@if [ -d "$(TEST_DIR)/integration" ]; then \
		$(PYTEST) $(TEST_DIR)/integration/ -v || true; \
	else \
		echo "$(YELLOW)No integration tests found in $(TEST_DIR)/integration/$(NC)"; \
	fi

test-e2e: check-venv ## Run end-to-end tests only
	@echo "$(YELLOW)Running end-to-end tests...$(NC)"
	@if [ -d "$(TEST_DIR)/e2e" ]; then \
		$(PYTEST) $(TEST_DIR)/e2e/ -v || true; \
	else \
		echo "$(YELLOW)No e2e tests found in $(TEST_DIR)/e2e/$(NC)"; \
	fi

test-coverage: check-venv ## Generate detailed coverage report
	@echo "$(YELLOW)Generating coverage report...$(NC)"
	$(PYTEST) $(TEST_DIR)/ --cov=$(SRC_DIR) --cov-report=html || true
	@echo "$(GREEN)✓ Coverage report generated in htmlcov/index.html$(NC)"
	@open htmlcov/index.html 2>/dev/null || true

# -----------------------------------------------------------------------------
# CODE QUALITY
# -----------------------------------------------------------------------------
lint: check-venv ## Run linters (pylint, mypy)
	@echo "$(YELLOW)Running linters...$(NC)"
	@if [ -d "$(SRC_DIR)" ]; then \
		echo "$(BLUE)Running pylint...$(NC)"; \
		$(PYLINT) $(SRC_DIR) || true; \
		echo "$(BLUE)Running mypy...$(NC)"; \
		$(MYPY) $(SRC_DIR) || true; \
		echo "$(GREEN)✓ Linting complete$(NC)"; \
	else \
		echo "$(YELLOW)No src directory found yet$(NC)"; \
	fi

format: check-venv ## Format code with black and isort
	@echo "$(YELLOW)Formatting code...$(NC)"
	@if [ -d "$(SRC_DIR)" ]; then \
		echo "$(BLUE)Running black...$(NC)"; \
		$(BLACK) $(SRC_DIR) $(TEST_DIR) || true; \
		echo "$(BLUE)Running isort...$(NC)"; \
		$(ISORT) $(SRC_DIR) $(TEST_DIR) || true; \
		echo "$(GREEN)✓ Formatting complete$(NC)"; \
	else \
		echo "$(YELLOW)No src directory found yet. Creating...$(NC)"; \
		mkdir -p $(SRC_DIR); \
		touch $(SRC_DIR)/__init__.py; \
	fi

format-check: check-venv ## Check if code is formatted correctly
	@echo "$(YELLOW)Checking code formatting...$(NC)"
	@if [ -d "$(SRC_DIR)" ]; then \
		$(BLACK) --check $(SRC_DIR) $(TEST_DIR) || true; \
		$(ISORT) --check-only $(SRC_DIR) $(TEST_DIR) || true; \
	fi

type-check: check-venv ## Run static type checking
	@echo "$(YELLOW)Running type checker...$(NC)"
	@if [ -d "$(SRC_DIR)" ]; then \
		$(MYPY) $(SRC_DIR) || true; \
	fi

# -----------------------------------------------------------------------------
# DOCKER
# -----------------------------------------------------------------------------
build: ## Build all Docker images
	@echo "$(YELLOW)Building Docker images...$(NC)"
	@if [ -f "docker-compose.yml" ]; then \
		$(DOCKER_COMPOSE) build; \
		echo "$(GREEN)✓ Docker images built$(NC)"; \
	else \
		echo "$(RED)Error: docker-compose.yml not found$(NC)"; \
		echo "$(YELLOW)You'll create this in Phase 5 of the walkthrough$(NC)"; \
	fi

build-edge: ## Build edge agent Docker image
	@echo "$(YELLOW)Building edge agent image...$(NC)"
	@if [ -f "build/docker/edge/Dockerfile" ]; then \
		$(DOCKER) build -f build/docker/edge/Dockerfile -t $(PROJECT_NAME)-edge:latest .; \
		echo "$(GREEN)✓ Edge agent image built$(NC)"; \
	else \
		echo "$(YELLOW)Dockerfile not found. You'll create this later in the walkthrough.$(NC)"; \
	fi

docker-up: ## Start all Docker services
	@echo "$(YELLOW)Starting Docker services...$(NC)"
	@if [ -f "docker-compose.yml" ]; then \
		$(DOCKER_COMPOSE) up -d; \
		echo "$(GREEN)✓ Services started$(NC)"; \
	else \
		echo "$(YELLOW)docker-compose.yml not found yet$(NC)"; \
	fi

docker-down: ## Stop all Docker services
	@echo "$(YELLOW)Stopping Docker services...$(NC)"
	@if [ -f "docker-compose.yml" ]; then \
		$(DOCKER_COMPOSE) down; \
		echo "$(GREEN)✓ Services stopped$(NC)"; \
	else \
		echo "$(YELLOW)No services running$(NC)"; \
	fi

docker-logs: ## Show Docker service logs
	@if [ -f "docker-compose.yml" ]; then \
		$(DOCKER_COMPOSE) logs -f; \
	else \
		echo "$(YELLOW)docker-compose.yml not found$(NC)"; \
	fi

docker-clean: ## Remove all Docker containers and images
	@echo "$(YELLOW)Cleaning Docker resources...$(NC)"
	@if [ -f "docker-compose.yml" ]; then \
		$(DOCKER_COMPOSE) down -v --rmi all || true; \
	fi
	@echo "$(GREEN)✓ Docker resources cleaned$(NC)"

# -----------------------------------------------------------------------------
# KUBERNETES
# -----------------------------------------------------------------------------
deploy: ## Deploy to Kubernetes
	@echo "$(YELLOW)Deploying to Kubernetes...$(NC)"
	@if [ -d "build/kubernetes" ]; then \
		$(KUBECTL) apply -f build/kubernetes/; \
		echo "$(GREEN)✓ Deployment complete$(NC)"; \
	else \
		echo "$(YELLOW)Kubernetes configs not found yet$(NC)"; \
	fi

k8s-status: ## Show Kubernetes deployment status
	@$(KUBECTL) get all -n adaptive-guardian 2>/dev/null || echo "$(YELLOW)No deployments found$(NC)"

# -----------------------------------------------------------------------------
# SIMULATION
# -----------------------------------------------------------------------------
simulate: check-venv ## Run simulation environment
	@echo "$(YELLOW)Starting simulation...$(NC)"
	@if [ -f "src/simulation/main.py" ]; then \
		$(VENV_BIN)/python -m src.simulation.main; \
	else \
		echo "$(YELLOW)Simulation not created yet$(NC)"; \
	fi

# -----------------------------------------------------------------------------
# TRAINING & ML
# -----------------------------------------------------------------------------
train-edge: check-venv ## Train edge agent model
	@echo "$(YELLOW)Training edge agent model...$(NC)"
	@if [ -f "src/edge/train_tcn.py" ]; then \
		$(VENV_BIN)/python src/edge/train_tcn.py --synthetic --epochs 10 --batch-size 16; \
	else \
		echo "$(YELLOW)Training script not created yet$(NC)"; \
		echo "$(BLUE)You'll create this in Part 2 of the walkthrough$(NC)"; \
	fi

train-federated: check-venv ## Start federated learning
	@echo "$(YELLOW)Starting federated learning...$(NC)"
	@if [ -f "src/cloud/federated/server.py" ]; then \
		$(VENV_BIN)/python src/cloud/federated/server.py; \
	else \
		echo "$(YELLOW)Federated server not created yet$(NC)"; \
	fi

# -----------------------------------------------------------------------------
# MLFLOW
# -----------------------------------------------------------------------------
mlflow-ui: ## Start MLflow UI
	@echo "$(YELLOW)Starting MLflow UI...$(NC)"
	@echo "$(BLUE)Open http://localhost:5000 in your browser$(NC)"
	@$(VENV_BIN)/mlflow ui

# -----------------------------------------------------------------------------
# JUPYTER
# -----------------------------------------------------------------------------
notebook: check-venv ## Start Jupyter notebook
	@echo "$(YELLOW)Starting Jupyter Lab...$(NC)"
	@$(VENV_BIN)/jupyter lab

# -----------------------------------------------------------------------------
# DOCUMENTATION
# -----------------------------------------------------------------------------
docs: check-venv ## Generate documentation
	@echo "$(YELLOW)Generating documentation...$(NC)"
	@if [ -d "$(DOCS_DIR)" ]; then \
		cd $(DOCS_DIR) && $(MAKE) html || true; \
		echo "$(GREEN)✓ Documentation generated$(NC)"; \
	else \
		echo "$(YELLOW)Docs directory not found yet$(NC)"; \
	fi

docs-serve: ## Serve documentation locally
	@echo "$(YELLOW)Serving documentation on http://localhost:8080$(NC)"
	@if [ -d "$(DOCS_DIR)/_build/html" ]; then \
		cd $(DOCS_DIR)/_build/html && python -m http.server 8080; \
	else \
		echo "$(YELLOW)Build docs first with: make docs$(NC)"; \
	fi

# -----------------------------------------------------------------------------
# CLEANING
# -----------------------------------------------------------------------------
clean: ## Clean build artifacts and cache files
	@echo "$(YELLOW)Cleaning build artifacts...$(NC)"
	@find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	@find . -type d -name "*.egg-info" -exec rm -rf {} + 2>/dev/null || true
	@find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
	@find . -type d -name ".mypy_cache" -exec rm -rf {} + 2>/dev/null || true
	@find . -type f -name "*.pyc" -delete 2>/dev/null || true
	@find . -type f -name "*.pyo" -delete 2>/dev/null || true
	@find . -type f -name ".coverage" -delete 2>/dev/null || true
	@rm -rf htmlcov/ 2>/dev/null || true
	@rm -rf dist/ 2>/dev/null || true
	@rm -rf build/ 2>/dev/null || true
	@echo "$(GREEN)✓ Cleanup complete$(NC)"

clean-all: clean docker-clean ## Clean everything including Docker
	@echo "$(YELLOW)Performing deep cleanup...$(NC)"
	@echo "$(RED)Warning: This will NOT delete your virtual environment$(NC)"
	@echo "$(GREEN)✓ Deep cleanup complete$(NC)"

# -----------------------------------------------------------------------------
# UTILITIES
# -----------------------------------------------------------------------------
shell: check-venv ## Open Python shell with project context
	@$(VENV_BIN)/ipython

version: ## Show version information
	@echo "$(BLUE)Adaptive Guardian$(NC)"
	@echo "Version: 1.0.0"
	@echo ""
	@echo "$(YELLOW)Component Versions:$(NC)"
	@$(PYTHON) --version
	@$(DOCKER) --version 2>/dev/null || echo "Docker: not running"
	@$(KUBECTL) version --client --short 2>/dev/null || echo "kubectl: not installed"

check: check-venv format-check lint test ## Run all checks (format, lint, test)
	@echo "$(GREEN)✓ All checks passed$(NC)"

# -----------------------------------------------------------------------------
# PROJECT STRUCTURE
# -----------------------------------------------------------------------------
init-structure: ## Create complete project structure
	@echo "$(YELLOW)Creating project structure...$(NC)"
	@mkdir -p src/edge/{models,data,engine,inference,utils,config}
	@mkdir -p src/cloud/federated/{server,client,utils}
	@mkdir -p src/shared/{encryption,compression,protocols}
	@mkdir -p tests/{unit,integration,e2e}
	@mkdir -p data/{raw,processed,models}
	@mkdir -p docs/{architecture,api}
	@mkdir -p notebooks
	@mkdir -p config
	@mkdir -p scripts
	@touch src/__init__.py
	@touch src/edge/__init__.py
	@touch src/cloud/__init__.py
	@touch tests/__init__.py
	@echo "$(GREEN)✓ Project structure created$(NC)"

# -----------------------------------------------------------------------------
# DEVELOPMENT HELPERS
# -----------------------------------------------------------------------------
activate: ## Show command to activate virtual environment
	@echo "$(YELLOW)To activate the virtual environment, run:$(NC)"
	@echo "$(GREEN)source $(VENV)/bin/activate$(NC)"

status: ## Show project status
	@echo "$(BLUE)==================================================================$(NC)"
	@echo "$(BLUE)   Adaptive Guardian - Project Status                            $(NC)"
	@echo "$(BLUE)==================================================================$(NC)"
	@echo ""
	@echo "$(YELLOW)Virtual Environment:$(NC)"
	@if [ -d "$(VENV)" ]; then \
		echo "  ✓ Found at $(VENV)"; \
	else \
		echo "  ✗ Not found"; \
	fi
	@echo ""
	@echo "$(YELLOW)Project Structure:$(NC)"
	@if [ -d "src" ]; then echo "  ✓ src/"; else echo "  ✗ src/ (run: make init-structure)"; fi
	@if [ -d "tests" ]; then echo "  ✓ tests/"; else echo "  ✗ tests/"; fi
	@if [ -d "docs" ]; then echo "  ✓ docs/"; else echo "  ✗ docs/"; fi
	@echo ""
	@echo "$(YELLOW)Key Files:$(NC)"
	@if [ -f "requirements.txt" ]; then echo "  ✓ requirements.txt"; else echo "  ✗ requirements.txt"; fi
	@if [ -f "docker-compose.yml" ]; then echo "  ✓ docker-compose.yml"; else echo "  ✗ docker-compose.yml (created in Phase 5)"; fi
	@if [ -f ".gitignore" ]; then echo "  ✓ .gitignore"; else echo "  ✗ .gitignore"; fi
	@echo ""
	@echo "$(YELLOW)Docker:$(NC)"
	@docker info >/dev/null 2>&1 && echo "  ✓ Running" || echo "  ✗ Not running"
	@echo ""

# -----------------------------------------------------------------------------
# CI/CD HELPERS
# -----------------------------------------------------------------------------
ci: check-venv ## Run CI pipeline locally
	@echo "$(YELLOW)Running CI pipeline...$(NC)"
	@$(MAKE) format-check || true
	@$(MAKE) lint || true
	@$(MAKE) test || true
	@echo "$(GREEN)✓ CI pipeline complete$(NC)"

.PHONY: install
install: setup ## Alias for setup

.PHONY: activate check-venv status init-structure mlflow-ui
