SHELL := /bin/bash

# Borrowed from https://stackoverflow.com/questions/18136918/how-to-get-current-relative-directory-of-your-makefile
curr_dir := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

# Borrowed from https://stackoverflow.com/questions/2214575/passing-arguments-to-make-run
rest_args := $(wordlist 2, $(words $(MAKECMDGOALS)), $(MAKECMDGOALS))
$(eval $(rest_args):;@:)

examples := $(shell ls $(curr_dir)/examples | xargs -I{} echo -n "examples/{}")
modules := $(shell ls $(curr_dir)/modules | xargs -I{} echo -n "modules/{}")
targets := $(shell ls $(curr_dir)/hack | grep '.sh' | sed 's/\.sh//g')
$(targets):
	@$(curr_dir)/hack/$@.sh $(rest_args)

help:
	#
	# Usage:
	#
	#   * [dev] `make generate`, generate README file.
	#           - `make generate examples/hello-world` only generate docs and schema under examples/hello-world directory.
	#           - `make generate docs examples/hello-world` only generate README file under examples/hello-world directory.
	#           - `make generate schema examples/hello-world` only generate schema.yaml under examples/hello-world directory.
	#
	#   * [dev] `make lint`, check style and security.
	#           - `LINT_DIRTY=true make lint` verify whether the code tree is dirty.
	#           - `make lint examples/hello-world` only verify the code under examples/hello-world directory.
	#
	#   * [dev] `make test`, execute unit testing.
	#           - `make test examples/hello-world` only test the code under examples/hello-world directory.
	#
	#   * [ci]  `make ci`, execute `make generate`, `make lint` and `make test`.
	#
	@echo


.DEFAULT_GOAL := ci
.PHONY: $(targets) examples $(examples) modules $(modules) tests docs schema
