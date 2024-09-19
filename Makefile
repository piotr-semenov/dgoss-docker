-include dockerfile-commons/recipes/clean-docker.mk
-include dockerfile-commons/recipes/lint-dockerfiles.mk
-include dockerfile-commons/docker-funcs.mk

SHELL := /bin/bash

IMAGE_NAME = semenovp/tiny-dgoss
VCS_REF=$(shell git rev-parse --short HEAD)


.PHONY: help
help:  ## Prints the help.
	@echo 'Commands:'
	@grep --no-filename -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) |\
	 awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'


.DEFAULT_GOAL := all
.PHONY: all
all: lint-dockerfiles build clean;


.PHONY: build
build: export BUILD_ARGS='vcsref="$(VCS_REF)"'
build:  ## Builds the image for Goss/DGoss.
	@$(call build_docker_image,"$(IMAGE_NAME):latest","$(BUILD_ARGS)",".")


.PHONY: clean
clean: clean-docker;
