# Image and version configuration
IMAGE_NAME=registry.inventec/infra/telegraf
GOLANG_VERSION=1.24.4
TELEGRAF_VERSION=1.35.1

# Proxy settings
HTTP_PROXY=http://10.190.81.209:3389
NO_PROXY=*.inventec.net

# Derived variables
IMAGE_TAG=${IMAGE_NAME}:${TELEGRAF_VERSION}-lite-alpine

.PHONY: all docker-build docker-push

all: docker-build

docker-build:
	@echo "Building Docker image ${IMAGE_TAG}..."
	docker build --rm -t ${IMAGE_TAG} \
		--build-arg http_proxy=${HTTP_PROXY} \
		--build-arg https_proxy=${HTTP_PROXY} \
		--build-arg no_proxy=${NO_PROXY} \
		--build-arg GOLANG_VERSION=${GOLANG_VERSION} \
		--build-arg TELEGRAF_VERSION=${TELEGRAF_VERSION} \
		.

docker-push: docker-build
	@echo "Pushing Docker image ${IMAGE_TAG}..."
	@docker push ${IMAGE_TAG}
