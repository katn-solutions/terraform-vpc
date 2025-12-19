.PHONY: help lint test fmt init validate tflint clean all test-unit

# Terraform parameters
TERRAFORM=terraform
TFLINT=tflint
WORK_DIR=v0
TEST_DIR=test

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

fmt: ## Format Terraform files
	@echo "Formatting Terraform files..."
	@cd $(WORK_DIR) && $(TERRAFORM) fmt -recursive

init: ## Initialize Terraform
	@echo "Initializing Terraform..."
	@cd $(WORK_DIR) && $(TERRAFORM) init -backend=false

validate: init ## Validate Terraform configuration
	@echo "Validating Terraform configuration..."
	@cd $(WORK_DIR) && $(TERRAFORM) validate

tflint: ## Run tflint
	@echo "Running tflint..."
	@cd $(WORK_DIR) && $(TFLINT) --init
	@cd $(WORK_DIR) && $(TFLINT) --format compact --minimum-failure-severity=error

lint: ## Run all linting (fmt check + tflint)
	@echo "Checking Terraform format..."
	@cd $(WORK_DIR) && $(TERRAFORM) fmt -check -recursive
	@$(MAKE) tflint

test: validate ## Run Terraform validation
	@echo "Terraform validation completed successfully"

test-unit: ## Run Terratest unit tests
	@echo "Running Terratest unit tests..."
	@cd $(TEST_DIR) && go test -v -timeout 10m

clean: ## Clean Terraform artifacts
	@echo "Cleaning Terraform artifacts..."
	@cd $(WORK_DIR) && rm -rf .terraform .terraform.lock.hcl
	@cd $(TEST_DIR) && go clean -testcache

all: lint test test-unit ## Run linting, validation, and unit tests (default target)

.DEFAULT_GOAL := all
