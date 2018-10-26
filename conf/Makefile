SHELL:=/bin/bash
TOP=${PWD}
export PATH:=".:${PATH}"
.PHONY: all clean distclean

all: Dockerfile.$(SERVICE_NAME) docker-compose.yml.$(SERVICE_NAME)

templater:
	@echo Get templater
	curl -fsSkL -o templater https://raw.githubusercontent.com/johanhaleby/bash-templater/master/templater.sh && chmod 755 templater

# dl_autoware:

Dockerfile.$(SERVICE_NAME): Dockerfile.in .config templater
	@./templater $<  -f .config | grep -v '^\s*$$' > $@
	@minid -f $@ > $@.new
	@[ -e $@.new ] && mv $@.new $@

.config: .config.in
	@cp $< $@
	@echo "AUTOWARE_VERSION=$(AUTOWARE_VERSION)" >> $@
	@echo "SERVICE_NAME=$(SERVICE_NAME)" >> $@
	@[ x$(SERVICE_NAME) != x"opengl" ]\
	&& echo "FROM=nvidia/cudagl:9.1-devel" >> $@\
	|| echo "FROM=nvidia/opengl:devel" >> $@

docker-compose.yml.$(SERVICE_NAME): docker-compose.yml.in .config templater
	@./templater $<  -f .config | grep -v '^\s*$$' > $@

clean:
	@rm -f *~ *.bak Dockerfile.$(SERVICE_NAME) docker-compose.yml.$(SERVICE_NAME) .config Dockerfile. docker-compose.yml.

distclean: clean
	@rm -f templater Dockerfile.*gl docker-compose.yml.*gl
