
ifeq ($(filter cppcheck_docker.mk, $(notdir $(MAKEFILE_LIST))), cppcheck_docker.mk)

CPPCHECK_DOCKER_MAKEFILE_PATH:=$(strip $(shell realpath "$(shell dirname "$(lastword $(MAKEFILE_LIST))")"))

.PHONY: cppcheck 
cppcheck: ## Print out cppcheck static analysis report for source code call with: make cppcheck CPP_PROJECT_DIRECTORY=/absolute/path/to/source
	cd "${CPPCHECK_DOCKER_MAKEFILE_PATH}" && \
    make _cppcheck
endif
