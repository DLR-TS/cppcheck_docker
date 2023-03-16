SHELL:=/bin/bash

.DEFAULT_GOAL := help

PROJECT="cppcheck"
VERSION="latest"
TAG="${PROJECT}:${VERSION}"

DOCKER_FILE= Dockerfile.cppcheck

ROOT_DIR:=$(shell dirname "$(realpath $(firstword $(MAKEFILE_LIST)))")
MAKEFLAGS += --no-print-directory
include ${ROOT_DIR}/cppcheck_docker.mk

.EXPORT_ALL_VARIABLES:
DOCKER_BUILDKIT?=1
DOCKER_CONFIG:=

.PHONY: help 
help:
	@awk 'BEGIN {FS = ":.*##"; printf "Usage: make \033[36m<target>\033[0m CPP_PROJECT_DIRECTORY=<absolute path to cpp source directory>\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.PHONY: all
all: build

.PHONY: clean 
clean:
	docker rm $$(docker ps -a -q --filter "ancestor=${TAG}") 2> /dev/null || true
	docker rmi $$(docker images -q ${TAG}) --force 2> /dev/null || true
	docker rmi ${TAG} --force 2> /dev/null

.PHONY: check_CPP_PROJECT_DIRECTORY
check_CPP_PROJECT_DIRECTORY:
	@[ "${CPP_PROJECT_DIRECTORY}" ] || ( echo "CPP_PROJECT_DIRECTORY is not set. You must provide a project directory. make <target> CPP_PROJECT_DIRECTORY=<absolute path to cpp source code>"; exit 1 )

.PHONY: build
build: clean ## build cppcheck docker image, happens automatically when make cppcheck is called.
	docker build --network host -t "${TAG}" -f "${DOCKER_FILE}" .

.PHONY: build_fast
build_fast: # Build docker context only if it does not already exist
	@[ ! -n "$$(docker images -q ${TAG})" ] && make build || true

.PHONY: cppcheck 
_cppcheck: build_fast check_CPP_PROJECT_DIRECTORY 
	docker run -v "${CPP_PROJECT_DIRECTORY}:/tmp/cpp_source_directory" ${TAG} |& \
    tee "${CPP_PROJECT_DIRECTORY}/cppcheck_report.log"; EXIT_CODE=$$PIPESTATUS; \
    BASE_DIR=$$(basename "${CPP_PROJECT_DIRECTORY}") && \
    mv "${CPP_PROJECT_DIRECTORY}/cppcheck_report.log" "${CPP_PROJECT_DIRECTORY}/$${BASE_DIR}_cppcheck_report.log" && \
    exit $$EXIT_CODE

.PHONY: cppcheck_demo
cppcheck_demo: ## Show a cppcheck demo with provided hello_world project
	make cppcheck CPP_PROJECT_DIRECTORY="$$(realpath ./hello_world)"
