GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
WHITE  := $(shell tput -Txterm setaf 7)
CYAN   := $(shell tput -Txterm setaf 6)
RESET  := $(shell tput -Txterm sgr0)

.PHONY: help
help: ## show this help.
	@echo 'Usage:'
	@echo '  ${GREEN}make${RESET} ${YELLOW}<target>${RESET}'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} { \
		if (/^[a-zA-Z_-]+:.*?##.*$$/) {printf "  ${GREEN}%-21s${YELLOW}%s${RESET}\n", $$1, $$2} \
		else if (/^## .*$$/) {printf "  ${CYAN}%s${RESET}\n", substr($$1,4)} \
		}' $(MAKEFILE_LIST)

.Phony: create-backend
create-backend: ## Create terraform remote backend storage account and container
	../scripts/set-up-terraform-remote-state.sh

.Phony: init
init: ## Initialize the Terraform configuration
	@terraform init

,Phony: plan
plan: ## Terraform plan
	@terraform plan

.Phony: apply
apply: ## Apply the Terraform configuration, will not ask for approval.
	@terraform apply -auto-approve

.Phony: destroy
destroy: ## Destroy the provisioned infrastructure, will not ask for approval.
	@terraform destroy -auto-approve

.Phony: initlock
initlock: init ## Initialize and lock providers
	@terraform providers lock -platform=darwin_arm64 -platform=darwin_amd64 -platform=linux_amd64 -platform=linux_arm64

.Phony: fmt
fmt: ## formatt the .tf files
	@terraform fmt -recursive

.Phony: format
format: fmt ## formatt the .tf files

.Phony: lock
lock: initlock ## Initialize and lock providers

.Phony: clean
clean: ## Clean the .terraform directory
	find . -type d -name ".terraform" -prune -exec rm -rf {} \;

.Phony: clean-all
clean-all: clean ## Clean the .terraform directory and .lock.hcl with azure logout.
	find . -name ".terraform.lock.hcl" -prune -exec rm -rf {} \;
	az logout
	az account clear

.Phony: update-manifests
update-manifests:
	../scripts/replace-client-ids-after-recreation.sh



.Phony: docs
docs: ## Generate terraform documentation. Require terraform-docs installed locally.
	terraform-docs markdown --sort-by required . > README.md