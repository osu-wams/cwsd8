# ==============================================================================
# OSU Drupal — container
# Usage: make help
# ==============================================================================

IMAGE=osuwams/drupal
MAJOR_VERSION=10
TAG_LATEST=$(MAJOR_VERSION)-latest
TAG_WEB_SERVER=$(MAJOR_VERSION)-apache
IMAGE_LATEST=$(IMAGE):$(TAG_LATEST)
IMAGE_PRODUCTION=$(IMAGE):$(TAG_WEB_SERVER)
IMAGE_DEVELOPMENT=$(IMAGE):$(TAG_WEB_SERVER)-dev
COMPOSER_AUTH_FILE := $(HOME)/.config/composer/auth.json

.DEFAULT_GOAL := help
.PHONY: help build build-production build-development push
help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

# -----------------------------------------------------------------------------
#  Build & Test
build: build-production build-development
# Build Production Image
build-production: ## Build image, tagged with git SHA + :local
	DOCKER_BUILDKIT=1 docker build \
		--secret id=composer_auth,src=$(COMPOSER_AUTH_FILE) \
		--target=production --platform=linux/amd64 \
		--tag=$(IMAGE_PRODUCTION) --tag=$(IMAGE_LATEST) .
	@echo "built $(IMAGE_PRODUCTION)"

# Build Development Image
build-development: ## Build image, tagged with git SHA + :local
	DOCKER_BUILDKIT=1 docker build \
		--secret id=composer_auth,src=$(COMPOSER_AUTH_FILE) \
		--target=development --platform=linux/amd64 \
		--tag=$(IMAGE_DEVELOPMENT) .
	@echo "built $(IMAGE_DEVELOPMENT)"

push: ## Push Tagged Images to Docker Registry
	docker push $(IMAGE_PRODUCTION); \
	docker push $(IMAGE_DEVELOPMENT)
	@echo "digest for task definition:"
	@docker inspect --format='{{index .RepoDigests 0}}' $(IMAGE)

