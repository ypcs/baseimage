ARCH ?= $(shell dpkg --print-architecture)
_LOCAL_ARCH = $(shell dpkg --print-architecture)
DOCKER ?= docker

MMDEBSTRAP_FLAGS = --debug \
				   --mode=auto \
				   --keyring=trusted.gpg.d \
				   --setup=./hooks.d/setup.sh \
				   --variant=minbase \
				   --verbose

# Supported Debian suites
DEBIAN_SUITES = $(shell grep '^DEBIAN_SUITES=' config |cut -d\" -f2)

# Supported Ubuntu suites
UBUNTU_SUITES = $(shell grep '^UBUNTU_SUITES=' config |cut -d\" -f2)

SUPPORTED_TARGETS = $(DEBIAN_SUITES) $(UBUNTU_SUITES)

KEYRINGS = $(wildcard trusted.gpg.d/*.gpg)

ifneq ($(ARCH), $(_LOCAL_ARCH))
	MMDEBSTRAP_FLAGS := $(MMDEBSTRAP_FLAGS) --arch=$(ARCH)
endif

all:
	echo $(DEBIAN_SUITES)
	echo $(UBUNTU_SUITES)
	echo $(SUPPORTED_TARGETS)
all: clean $(SUPPORTED_TARGETS)

clean:
	rm -f *.rootfs.tar
	rm -f *.sources.list

install-dependencies:
	apt-get install mmdebstrap ubuntu-archive-keyring qemu-user-static binfmt-support

refresh-keyrings:
	$(foreach keyring,$(KEYRINGS),$(shell gpg --no-default-keyring --keyring=$(keyring) --keyserver=keyserver.ubuntu.com --refresh-keys))

%.sources.list:
	./scripts/generate-sources-list.sh $(patsubst %.$(ARCH).sources.list,%,$@) |tee $@

%.$(ARCH).rootfs.tar: %.$(ARCH).sources.list
	mmdebstrap $(MMDEBSTRAP_FLAGS) $(patsubst %.$(ARCH).rootfs.tar,%,$@) $@ - < $<

$(SUPPORTED_TARGETS): %: %.$(ARCH).rootfs.tar
