# Makefile for managing project dependencies and tools
PROJECT 		:= $(shell basename `git rev-parse --show-toplevel`)
COMMIT          := $(shell git rev-parse --short HEAD)
BRANCH          := $(shell git rev-parse --abbrev-ref HEAD)
REMOTE 		    := $(shell git remote get-url origin)
USER 		    := $(shell git config user.username)
CHANGES         := $(shell git status --porcelain | wc -l | xargs)

# Tool versions
GRYPE_VERSION   ?= 0.95.0
SYFT_VERSION    ?= 1.28.0

# Default target
all: help

.PHONY: info
info: ## Prints the current project info
	@echo "Project:"
	@echo "  name:              $(PROJECT)"
	@echo "  commit:            $(COMMIT)"
	@echo "  branch:            $(BRANCH)"
	@echo "  remote:            $(REMOTE)"
	@echo "  user:              $(USER)"
	@echo "  changes:           $(CHANGES)"
	@echo "Versions:"
	@echo "  grype version:     $(GRYPE_VERSION)"
	@echo "  syft version:      $(SYFT_VERSION)"

.PHONY: shas
shas: ## Retrieves SHA256 checksums for all tools (for Dockerfile COPY)
	@set -e; \
	echo "🔐 Fetching SHA256 for Grype v${GRYPE_VERSION}..."; \
	curl -fsSL https://github.com/anchore/grype/releases/download/v${GRYPE_VERSION}/grype_${GRYPE_VERSION}_checksums.txt \
	| grep 'linux_amd64.tar.gz' \
	| awk '{print $$1}'; \
	echo "🔐 Fetching SHA256 for Syft v${SYFT_VERSION}..."; \
	curl -fsSL https://github.com/anchore/syft/releases/download/v${SYFT_VERSION}/syft_${SYFT_VERSION}_checksums.txt \
	| grep 'linux_amd64.tar.gz' \
	| awk '{print $$1}'

.PHONY: help
help: ## Displays available commands
	@echo "Available make targets:"; \
	grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk \
		'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
