#!/bin/sh
set -e
set -x

BASEDIR="$(dirname "$(dirname "$0")")"
SUITE="${1:-bullseye}"
TARGET="${BASEDIR}/build"
TEMPDIR="$(mktemp --directory --tempdir baseimage.XXXXXX)"

echo "Building images for '${SUITE}'."
echo "Using '${TARGET}' as target directory."
echo "Using '${TEMPDIR}' as temporary directory."


#
# Setup hooks
#
HOOKSDIR="${TEMPDIR}/hooks"
mkdir -p "${HOOKSDIR}"

echo "I: Copy generic hooks..."
cp -a "${BASEDIR}/hooks/"* "${TARGET}/hooks/"

if [ -d "${BASEDIR}/suites/${SUITE}/hooks" ]
then
    cp -a "${BASEDIR}/suites/${SUITE}/hooks/"* "${TARGET}/hooks/"
else
    echo "W: No suite hooks directory."
fi

#
# Setup rootfs
#


#
# Build the image
#

if [ ! -x /usr/bin/mmdebstrap ]
then
    echo "mmdebstrap binary not found!" >&2
    exit 1
fi

BASETARFILE="${TEMPDIR}/${SUITE}.base.tar"
BASELOGFILE="${TEMPDIR}/${SUITE}.mmdebstrap.log"

echo "I: Build base image with $(/usr/bin/mmdebstrap --version)..."
/usr/bin/mmdebstrap \
    --architecture="${ARCH:-amd64}" \
    --format=tar \
    --hook-directory="${TARGET}/hooks" \
    --mode=fakechroot \
    --variant=minbase \
    --verbose \
    "${SUITE}" \
    "${BASETARFILE}" 2>&1|tee "${BASELOGFILE}"


#
# Checksums and image contents for verification
#

tar xvf \
    "${TARGET}/${SUITE}.base.tar" \
    --to-command sha256sum |tee "${TARGET}/${SUITE}.base.tar.sha256sums"


mkdir -p "${TARGET}"


