
ifndef cppcheck_docker

cppcheck_docker:=""

.PHONY: cppcheck 
cppcheck: ## Print out cppcheck static analysis report for source code.
	find . -name "**cppcheck_report.log" -exec rm -rf {} \;
	cd cppcheck_docker && \
    make cppcheck CPP_PROJECT_DIRECTORY=$$(realpath ${ROOT_DIR}/${PROJECT}) | \
	tee ${ROOT_DIR}/${PROJECT}/${PROJECT}_cppcheck_report.log; exit $$PIPESTATUS

endif