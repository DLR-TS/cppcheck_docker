SHELL:=/bin/bash

.DEFAULT_GOAL := help

PROJECT="cppcheck"
VERSION="latest"
TAG="${PROJECT}:${VERSION}"

DOCKER_FILE= Dockerfile.cppcheck

ROOT_DIR:=$(shell dirname "$(realpath $(firstword $(MAKEFILE_LIST)))")
MAKEFLAGS += --no-print-directory
.EXPORT_ALL_VARIABLES:
DOCKER_BUILDKIT?=1
DOCKER_CONFIG?=



.PHONY: help 
help:
	@awk 'BEGIN {FS = ":.*##"; printf "Usage: make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.PHONY: all
all: build

.PHONY: clean 
clean:
	docker rm $$(docker ps -a -q --filter "ancestor=${TAG}") 2> /dev/null || true
	docker rmi $$(docker images -q ${TAG}) 2> /dev/null || true
	docker rmi ${TAG} --force 2> /dev/null

.PHONY: build
build: clean ## build cppcheck docker image
	docker build -t "${TAG}" -f "${DOCKER_FILE}" .

.PHONY: cppcheck 
cppcheck: ## cppcheck provided source directory call with: make cppcheck CPP_PROJECT_DIRECTORY=/absolute/path/to/source
	@[ -n "$$(docker images -q ${TAG} 2> /dev/null)" ] && \
          echo "" || \
          make build
	docker run -v "${CPP_PROJECT_DIRECTORY}:/home/${PROJECT}/$$(basename ${CPP_PROJECT_DIRECTORY})" "${TAG}"

.PHONY: cppcheck_demo
cppcheck_demo: ## show a demo with provided hello_world project
	make cppcheck CPP_PROJECT_DIRECTORY="$$(realpath ./hello_world)"
