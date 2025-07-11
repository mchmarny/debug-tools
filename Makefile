# Makefile for managing project dependencies and tools
PROJECT 		:= $(shell basename `git rev-parse --show-toplevel`)
COMMIT          := $(shell git rev-parse --short HEAD)
BRANCH          := $(shell git rev-parse --abbrev-ref HEAD)
REMOTE 		    := $(shell git remote get-url origin)
USER 		    := $(shell git config user.username)
CHANGES         := $(shell git status --porcelain | wc -l | xargs)
REGISTRY        := ghcr.io
IMAGE           := $(REGISTRY)/$(USER)/$(PROJECT)

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
	@echo "  registry:          $(REGISTRY)"
	@echo "  image:             $(IMAGE)"
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


.PHONY: builder
builder: ## Builds the multi-architecture builder image
	@set -e; \
	if ! docker buildx inspect $(PROJECT) >/dev/null 2>&1; then \
		docker buildx create --name $(PROJECT) --driver docker-container --use; \
	else \
		echo "Builder $(PROJECT) already exists, switching to it"; \
		docker buildx use $(PROJECT); \
	fi; \
	docker buildx inspect --bootstrap; \
	docker buildx ls

.PHONY: image
image: ## Builds and pushes the multi-arch tools image
	@set -e; \
	echo "$(GITHUB_TOKEN)" | docker login $(REGISTRY) -u oauthtoken --password-stdin; \
	docker buildx build --no-cache --force-rm --platform linux/amd64,linux/arm64 \
		-t "$(IMAGE):$(COMMIT)" \
		-f tools.docker \
		--push .; \
	echo "Image built and pushed successfully: $(IMAGE):$(COMMIT)"; \
	echo "Verifying image..."; \
	docker buildx imagetools inspect "$(IMAGE):$(COMMIT)"

.PHONY: run
run: ## Run tools image locally
	@set -e; \
	docker pull "$(IMAGE):latest"; \
	docker run -it "$(IMAGE):latest" bash

.PHONY: help
help: ## Displays available commands
	@echo "Available make targets:"; \
	grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk \
		'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
