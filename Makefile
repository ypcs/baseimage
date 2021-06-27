APT_PROXY ?=
DOCKER ?= docker
NAMESPACE = docker.io/ypcs

DEBIAN_SUITES = buster sid bullseye
DEBIAN_MIRROR ?= http://deb.debian.org/debian

UBUNTU_SUITES = xenial bionic focal hirsute
UBUNTU_MIRROR ?= http://archive.ubuntu.com/ubuntu

SUITES = $(DEBIAN_SUITES) $(UBUNTU_SUITES)

all: $(SUITES)

clean:
	rm -rf tmp.* build

$(SUITES): %:
	sh build.sh "$@"

build-container:
	$(DOCKER) build \
		--build-arg APT_PROXY="$(APT_PROXY)" \
		--tag "$(NAMESPACE)/baseimage:latest" .
