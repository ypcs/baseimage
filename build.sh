#!/bin/sh
set -e

DISTRO="$1"
RELEASE="$2"

case "${DISTRO}"
in
    debian)
        MIRROR="https://deb.debian.org/debian"
    ;;
    ubuntu)
	MIRROR="https://archive.ubuntu.com/ubuntu"
    ;;
    *)
        echo "Invalid release '${RELEASE}'!"
        exit 1
    ;;
esac

TARGET="chroot-${RELEASE}"

/usr/sbin/debootstrap \
    --variant=minbase \
    --force-check-gpg \
    "${RELEASE}" \
    "${TARGET}" \
    "${MIRROR}"

rsync --chown=root:root -avh rootfs/* "${TARGET}/"

case "${DISTRO}"
in
    debian)
        chroot "${TARGET}" bash -c 'DEBIAN_MIRROR="${MIRROR}" DISTRIBUTION="debian" CODENAME="${RELEASE}" /bin/bash /usr/lib/baseimage-helpers/build/execute'
    ;;
    ubuntu)
        chroot "${TARGET}" bash -c 'UBUNTU_MIRROR="${MIRROR}" DISTRIBUTION="ubuntu" CODENAME="${RELEASE}" /bin/bash /usr/lib/baseimage-helpers/build/execute'
    ;;
    *)
        echo "Invalid release '${RELEASE}'!"
        exit 1
    ;;
esac

