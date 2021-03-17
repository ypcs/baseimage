# Base images for containers etc.

This repository contains various scripts for generating somewhat standardized
Debian/Ubuntu base images for containers and other usages.

Docker images built using these scripts are available at Docker Hub:
[ypcs/debian](https://hub.docker.com/r/ypcs/debian) and
[ypcs/ubuntu](https://hub.docker.com/r/ypcs/ubuntu).  ## Debian images This
assumes that your build host is Debian, and you've installed docker.io package.


## Dependencies

    apt-get install debian-archive-keyring mmdebstrap ubuntu-archive-keyring parallel signify-openbsd libguestfs-tools


## Variants

This tool is written so that multiple variants can be easily built from single
source.

 - architecture (amd64, armhf, ...)
 - distribution (Debian, Ubuntu, ...)
 - release (buster, bullseye, sid, ..., bionic, focal, hirsute)
 - platforms (chroot, docker, disk image, ...)



## Verify artifacts
This uses OpenBSD's `signify` to verify cryptographic signatures.

Each build from this tool by default generates both SHA256 and SHA512
checksums, and then signs these files so that you can verify the authencity of
all published artifacts.

    signify ...

All published artifacts since xx.xx.2021 will contain the public key used to
verify build artifacts.

All Debian/Ubuntu images are published with also SHA256 lists of all included
files, and with simple script you can verify which parts come directly from
upstream release and what has been modified by build tools. This makes it much
easier to verify that there is no eg. hidden changes to binary files.


### Build images
### Install VM from webserver

Use

    http://192.168.122.1:3142/deb.debian.org/debian/dists/stable/main/installer-amd64/

as installer URL and set kernel parameters

    auto debian-installer/locale=en_US.UTF-8 keyboard-configuration/xkb-keymap=us netcfg/choose_interface=auto netcfg/get_hostname=localhost netcfg/get_domain=localdomain url=ypcs.fi

to execute fully automated installation without any prompts. These assume you
have local `apt-cacher-ng` instance running at IP 192.168.122.1, which is
default network bridge for QEMU/KVM on my env.
