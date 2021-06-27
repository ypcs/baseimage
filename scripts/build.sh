#!/bin/sh
set -e
set -x

BASEDIR="$(dirname "$(dirname "$0")")"
SUITE="${1:-bullseye}"
TARGET="${BASEDIR}/build"
TEMPDIR="$(mktemp --directory --tmpdir baseimage.XXXXXX)"

echo "Building images for '${SUITE}'."
echo "Using '${TARGET}' as target directory."
echo "Using '${TEMPDIR}' as temporary directory."


#
# Setup hooks
#
HOOKSDIR="${TEMPDIR}/hooks"
mkdir -p "${HOOKSDIR}"

echo "I: Copy generic hooks..."
cp -a "${BASEDIR}/hooks/"* "${HOOKSDIR}/"

SUITEHOOKDIR="${BASEDIR}/suites/${SUITE}/hooks"
if [ -d "${SUITEHOOKDIR}" ]
then
    cp -a "${SUITEHOOKDIR}/"* "${HOOKSDIR}/"
else
    echo "W: No suite hooks directory."
fi

# Configure APT proxying if one of APT_PROXY, http_proxy or HTTP_PROXY variable
# is set. This is the order of preference.
APT_PROXY="${APT_PROXY:-${http_proxy:-${HTTP_PROXY}}}"

if [ -n "${APT_PROXY}" ]
then
    echo "APT: '${APT_PROXY}'"
fi
exit 0

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


