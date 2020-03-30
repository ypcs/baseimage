#!/bin/sh
set -e

DISTRO="$1"
CODENAME="$2"
BUILD_ID="${BUILD_ID:-$(git describe --always)-$(date +%Y%m%d%H%M)}"

usage() {
    echo "usage: $0 <distribution> <codename>"
}

[ -z "${DISTRO}" ] && usage && exit 1
[ -z "${CODENAME}" ] && usage && exit 1

BASEDIR="$(realpath "$(dirname "$0")")"
CACHE_DIR="${BASEDIR}/cache"

if [ ! -d "${CACHE_DIR}" ]
then
    mkdir -p "${CACHE_DIR}"
fi

# TODO: If specific script not foumd, fallback to latest for same distro
# TODO: Add support for cleaning up cruft and/or use temporary build dirs

case "${DISTRO}"
in
    debian)
        MIRROR="${DEBIAN_MIRROR:-https://deb.debian.org/debian}"
	case "${CODENAME}"
	in
            sid)
	    ;;
            bullseye|buster|stretch|jessie)
            ;;
            testing|stable|oldstable|oldoldstable)
	    ;;
            *)
                echo "Unknown/unsupported release: '${CODENAME}'."
		exit 1
	    ;;
	esac
    ;;
    ubuntu)
	MIRROR="${UBUNTU_MIRROR:-http://archive.ubuntu.com/ubuntu}"
	case "${CODENAME}"
	in
            eoan|bionic|xenial)
	    ;;
            *)
                echo "Unknown/unsupported release: '${CODENAME}'."
                exit 1
	    ;;
	esac
    ;;
    *)
        echo "Invalid release '${CODENAME}'!"
        exit 1
    ;;
esac

if [ -z "${CODENAME}" ]
then
    echo "Missing release!"
    exit 1
fi

echo "I: Building ${DISTRO}/${CODENAME} using '${MIRROR}' as mirror."

TEMPDIR="$(mktemp --directory "${BASEDIR}/tmp.build.${BUILD_ID}.XXXXXX")"

echo "I: Using '${TEMPDIR}' as temporary directory."

ARTIFACTS="${BASEDIR}/artifacts/${BUILD_ID}"
mkdir -p "${ARTIFACTS}"

if [ "$(id -u)" != "0" ]
then
    echo "E: This script must be run as root!"
    exit 1
fi

TARGET="${TEMPDIR}/chroot-${DISTRO}-${CODENAME}"

TARBALL="${ARTIFACTS}/debootstrap_${DISTRO}-${CODENAME}.tar"

echo "I: Create debootstrap tarball..."
/usr/sbin/debootstrap \
    --make-tarball="${TARBALL}" \
    --variant=minbase \
    --force-check-gpg \
    --log-extra-deps \
    --cache-dir="${CACHE_DIR}" \
    "${CODENAME}" \
    "${TARGET}.tarball" \
    "${MIRROR}" \
    "/usr/share/debootstrap/scripts/${CODENAME}"

echo "I: Create actual chroot directory..."
/usr/sbin/debootstrap \
    --unpack-tarball="${TARBALL}" \
    --variant=minbase \
    --force-check-gpg \
    --log-extra-deps \
    --cache-dir="${CACHE_DIR}" \
    "${CODENAME}" \
    "${TARGET}" \
    "${MIRROR}" \
    "/usr/share/debootstrap/scripts/${CODENAME}"

cat > "${TARGET}/envfile" << EOF
# Environment configuration for baseimage
export MIRROR="${MIRROR}"
export DISTRIBUTION="${DISTRO}"
export CODENAME="${CODENAME}"
EOF

echo "I: Sync rootfs to chroot..."
rsync --exclude=.gitignore --chown=root:root -avh rootfs/* "${TARGET}/"

tar -C "${TARGET}" -cf "${ARTIFACTS}/chroot_${DISTRO}-${CODENAME}.tar" "${TARGET}"

VARIANTS_DIR="${BASEDIR}/variants"
for variant in $(find "${VARIANTS_DIR}" -maxdepth 1 -type d -print)
do
    if [ "${variant}" = "${VARIANTS_DIR}" ]
    then
        continue
    fi
    VAR="$(basename "${variant}")"
    echo "I: Build variant '${VAR}'..."
    VTARGET="${TARGET}-${VAR}"
    rsync -avh "${TARGET}/" "${VTARGET}"
    rsync --exclude=.gitignore -avh "${variant}/" "${VTARGET}"
    chroot "${VTARGET}" /bin/bash /usr/lib/baseimage-helpers/build/execute
    tar -C "${VTARGET}" -cf "${ARTIFACTS}/variant_${DISTRO}-${CODENAME}_${VAR}.tar" "${VTARGET}"
done
