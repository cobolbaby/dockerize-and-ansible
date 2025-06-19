# Makefile for Go HTTP Proxy with Docker build/push

APP_NAME := proxy-webhook
BUILD_DIR := bin
SRC := main.go
DOCKER_IMAGE := registry.inventec/infra/$(APP_NAME)
TAG ?= latest

.PHONY: all build run clean docker-build docker-push

all: build

build:
	@echo "Building $(APP_NAME)..."
	@mkdir -p $(BUILD_DIR)
	@CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o $(BUILD_DIR)/$(APP_NAME) $(SRC)
	@echo "Build complete: $(BUILD_DIR)/$(APP_NAME)"

run: build
	@echo "Running $(APP_NAME)..."
	@./$(BUILD_DIR)/$(APP_NAME)

clean:
	@echo "Cleaning build artifacts..."
	@rm -rf $(BUILD_DIR)
	@echo "Clean complete."

docker-build: build
	@echo "Building Docker image $(DOCKER_IMAGE):$(TAG)..."
	@docker build -t $(DOCKER_IMAGE):$(TAG) .

docker-push: docker-build
	@echo "Pushing Docker image $(DOCKER_IMAGE):$(TAG)..."
	@docker push $(DOCKER_IMAGE):$(TAG)
