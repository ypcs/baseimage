#!/bin/sh
set -e

DISTRO="$1"
RELEASE="$2"
CACHE_DIR="$(realpath "$(dirname "$0")/cache")"

if [ ! -d "${CACHE_DIR}" ]
then
    mkdir -p "${CACHE_DIR}"
fi

case "${DISTRO}"
in
    debian)
        MIRROR="${DEBIAN_MIRROR:-https://deb.debian.org/debian}"
	case "${RELEASE}"
	in
            sid)
	    ;;
            bullseye|buster|stretch|jessie)
            ;;
            testing|stable|oldstable|oldoldstable)
	    ;;
            *)
                echo "Unknown/unsupported release: '${RELEASE}'."
		exit 1
	    ;;
	esac
    ;;
    ubuntu)
	MIRROR="${UBUNTU_MIRROR:-https://archive.ubuntu.com/ubuntu}"
	case "${RELEASE}"
	in
            eoan|bionic|xenial)
	    ;;
            *)
                echo "Unknown/unsupported release: '${RELEASE}'."
                exit 1
	    ;;
	esac
    ;;
    *)
        echo "Invalid release '${RELEASE}'!"
        exit 1
    ;;
esac

if [ -z "${RELEASE}" ]
then
    echo "Missing release!"
    exit 1
fi

echo "I: Building ${DISTRO}/${RELEASE} using '${MIRROR}' as mirror."

TARGET="chroot-${RELEASE}"

if [ "$(id -u)" = "0" ]
then
    DEBOOTSTRAP="/usr/sbin/debootstrap"
else
    DEBOOTSTRAP="/usr/bin/sudo /usr/sbin/debootstrap"
fi

${DEBOOTSTRAP} \
    --variant=minbase \
    --force-check-gpg \
    --cache-dir="${CACHE_DIR}" \
    "${RELEASE}" \
    "${TARGET}" \
    "${MIRROR}" #\
#    "/usr/share/debootstrap/scripts/${RELEASE}"
exit 1
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

