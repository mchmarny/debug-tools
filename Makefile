# Global variables
REPO_NAME       := debug-tools
VERSION         := $(shell cat .version)
YAML_FILES      := $(shell find . -type f \( -iname "*.yml" -o -iname "*.yaml" \) ! -path "./vendor/*" ! -path "./example/*")
REGISTRY        := ghcr.io
IMAGE_URI       := $(REGISTRY)/mchmarny/$(REPO_NAME)
SBOM_FILE       := sbom.json
SBOM_FORMAT     := cyclonedx-json
ATTEST_FORMAT   := cyclonedx

# Default target
all: help

.PHONY: info
info: ## Prints the current project info
	@echo "Project Information:"
	@echo "  Version:            $(VERSION)"
	@echo "  Image Registry:     $(REGISTRY)"
	@echo "  Image URI:          $(IMAGE_URI):$(VERSION)"
	@echo "  SBOM file:          $(SBOM_FILE)"
	@echo "  SBOM format:        $(SBOM_FORMAT)"
	@echo "  Attestation format: $(ATTEST_FORMAT)"

.PHONY: init 
init: ## Initializes the project environment
	@set -e; \
	rm -f cosign.key cosign.pub || exit 1; \
	echo "Generating cosign key pair..."; \
	COSIGN_PASSWORD="$(COSIGN_PASSWORD)" cosign generate-key-pair

.PHONY: builder
builder: ## Builds the multi-architecture builder image
	@set -e; \
	if ! docker buildx inspect $(REPO_NAME) >/dev/null 2>&1; then \
		docker buildx create --name $(REPO_NAME) --driver docker-container --use; \
	else \
		echo "Builder $(REPO_NAME) already exists, switching to it"; \
		docker buildx use $(REPO_NAME); \
	fi; \
	docker buildx inspect --bootstrap; \
	docker buildx ls

.PHONY: image
image: ## Builds and pushes the multi-arch tools image
	@set -e; \
	echo "$(GITHUB_TOKEN)" | docker login $(REGISTRY) -u oauthtoken --password-stdin; \
	docker buildx build --no-cache --force-rm --platform linux/amd64,linux/arm64 \
		-t "$(IMAGE_URI):$(VERSION)" \
		-f tools.docker \
		--push .; \
	echo "Image built and pushed successfully: $(IMAGE_URI):$(VERSION)"; \
	echo "Verifying image..."; \
	docker buildx imagetools inspect "$(IMAGE_URI):$(VERSION)"; \
	echo "Saving digest to .digest file..."; \
	crane digest --full-ref "$(IMAGE_URI):$(VERSION)" > .digest; \
	echo "Digest saved: $$(cat .digest)"

.PHONY: sbom
sbom: ## Generates a Software Bill of Materials (SBOM)
	@set -e; \
	echo "Generating SBOM"; \
	syft scan "$(shell cat .digest)" -q -s all-layers -o "${SBOM_FORMAT}=${SBOM_FILE}" || exit 1; \
	echo "SBOM generated successfully: ${SBOM_FILE}"

.PHONY: scan
scan: ## Scans for source vulnerabilities
	@set -e; \
	echo "Scanning for vulnerabilities"; \
	grype "$(shell cat .digest)" -f high -o table

.PHONY: attest
attest: ## Generates and verifies an attestation for the tools image
	@set -e; \
	COSIGN_PASSWORD="$(COSIGN_PASSWORD)" cosign attest -y --replace --key cosign.key --predicate $(SBOM_FILE) \
		--type "$(ATTEST_FORMAT)" "$(shell cat .digest)"
	@echo "Attestation generated successfully for $(shell cat .digest)"
	cosign verify-attestation --type "$(ATTEST_FORMAT)" --key cosign.pub "$(shell cat .digest)" \
		| jq -r '.payload | @base64d | fromjson | .predicate' > ./predicate.json

.PHONY: run
run: ## Run tools image locally
	@set -e; \
	docker run -it "$(shell cat .digest)" bash

.PHONY: help
help: ## Displays available commands
	@echo "Available make targets:"; \
	grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk \
		'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
