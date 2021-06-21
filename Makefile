NAMESPACE = ypcs

DEBIAN_SUITES = buster sid bullseye
DEBIAN_MIRROR ?= http://deb.debian.org/debian

UBUNTU_SUITES = xenial bionic focal hirsute
UBUNTU_MIRROR ?= http://archive.ubuntu.com/ubuntu

SUITES = $(DEBIAN_SUITES) $(UBUNTU_SUITES)

ARCH ?= amd64

all: clean build

build: $(SUITES)

clean:
	# %.tar
	rm -f *.tar *.tar.log
	# %.hooks
	rm -rf *.hooks

$(SUITES): %: %.$(ARCH).tar %.$(ARCH).raw.mbr %.$(ARCH).raw.gpt

%.sources:

suites/%/hooks:
	mkdir -p $@

%.hooks/ok:
	# FIXME: copy all hooks for this *release*/suite
	cp -a hooks $(dir $@)
	cp -a suites/$(basename $(dir $@))/hooks/* $(dir $@) || true
	touch $@

%.tar: $(basename %).hooks/ok
	@echo "Build base image using $(shell mmdebstrap --version)..."
	@echo " Suite: $(basename $(basename $@))"
	@echo " Target file: $@"
	@echo " Architecture: $(ARCH)"
	mmdebstrap \
		--architecture "$(ARCH)" \
		--format tar \
		--hook-directory=$(basename $@).hooks \
		--logfile=$@.log \
		--mode=fakechroot \
		--variant=minbase \
		--verbose \
		"$(basename $(basename $@))" \
		"$@"
