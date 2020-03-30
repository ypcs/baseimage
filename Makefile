NAMESPACE = ypcs

DEBIAN_SUITES = stretch buster sid bullseye
DEBIAN_MIRROR ?= http://deb.debian.org/debian

UBUNTU_SUITES = bionic xenial eoan
UBUNTU_MIRROR ?= http://archive.ubuntu.com/ubuntu

SUDO = /usr/bin/sudo
DEBOOTSTRAP = /usr/sbin/debootstrap
DEBOOTSTRAP_FLAGS = --variant=minbase
TAR = /bin/tar

DOCKER ?= docker

noop:
	@echo "FIXME"

all: clean $(DEBIAN_SUITES) $(UBUNTU_SUITES)

clean:
	rm -rf *.tar *.tar.gz chroot-*
	rm -rf tmp.*

$(DEBIAN_SUITES): % : debian-%.tar

$(UBUNTU_SUITES): % : ubuntu-%.tar

%.tar: chroot-%

chroot-debian-%:
	sh build.sh debian $*

chroot-ubuntu-%:
	sh build.sh ubuntu $*

images:
	$(MAKE) -C $@

.PHONY: images
