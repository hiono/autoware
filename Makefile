SHELL:=/bin/bash
export PATH:=".:${PATH}"
TOP=${PWD}
# VPATH=../base
SERVICE=$(shell basename ${PWD})

# SERVICE_NAME=cudagl
SERVICE_NAME=opengl
AUTOWARE_VERSION=1.7.0

.PHONY: all dl_autoware build sh clean distclean

all: sh

dl_autoware:
	@[ ! -d Autoware ] && git clone https://github.com/CPFL/Autoware.git --recurse-submodules || (source conf/.config; cd Autoware; git checkout master; git pull --all --recurse-submodules=yes; git describe --tags --abbrev=0; git checkout refs/tags/$${AUTOWARE_VERSION})

conf/.config: conf/.config.in
	@$(MAKE) -C conf $(nodir $@) AUTOWARE_VERSION=$(AUTOWARE_VERSION) SERVICE_NAME=$(SERVICE_NAME)

conf/Dockerfile.$(SERVICE_NAME): conf/Dockerfile.in conf/.config
	@$(MAKE) -C conf $(nodir $@)

conf/docker-compose.yml.$(SERVICE_NAME): conf/docker-compose.yml.in conf/.config
	@$(MAKE) -C conf $(nodir $@)

build: conf/docker-compose.yml.$(SERVICE_NAME) conf/Dockerfile.$(SERVICE_NAME)
	@echo Build image
	COMPOSE_PROJECT_NAME=autoware docker-compose -f $< build

sh: conf/docker-compose.yml.$(SERVICE_NAME)
	@docker-compose -f $< run $(SERVICE) bash --login || exit 0

clean: Makefile
	@rm -f *~ *.bak
	@$(MAKE) -C conf $@

distclean: clean
	@rm -rf Autoware
	@$(MAKE) -C conf $@
