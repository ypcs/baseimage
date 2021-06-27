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
# APT proxy
#
# Configure APT proxying if one of APT_PROXY, http_proxy or HTTP_PROXY variable
# is set. This is the order of preference.
#
APT_PROXY="${APT_PROXY:-${http_proxy:-${HTTP_PROXY}}}"

if [ -n "${APT_PROXY}" ]
then
    export APT_PROXY
    echo "Use APT proxy: '${APT_PROXY}'"
    # FIXME: override current hook setup if needed
fi


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


#
# Setup rootfs
#
ROOTFSDIR="${TEMPDIR}/rootfs"
mkdir -p "${ROOTFSDIR}"

echo "I: Copy generic rootfs..."
cp -a "${BASEDIR}/rootfs/"* "${ROOTFSDIR}/"

SUITEROOTFSDIR="${BASEDIR}/suites/${SUITE}/rootfs"
if [ -d "${SUITEROOTFSDIR}" ]
then
    cp -a "${SUITEROOTFSDIR}/"* "${ROOTFSDIR}/"
else
    echo "W: No suite rootfs directory."
fi


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
    --hook-directory="${HOOKSDIR}" \
    --mode=fakechroot \
    --variant=minbase \
    --verbose \
    "${SUITE}" \
    "${BASETARFILE}" 2>&1|tee "${BASELOGFILE}"


#
# Checksums and image contents for verification
#

tar xvf \
    "${BASETARFILE}" \
    --to-command sha256sum |tee "${BASETARFILE}.sha256sums"

#
# Rootfs tar archive
#
echo "I: Creating rootfs tar archive..."
tar --directory="${ROOTFSDIR}" -c . -f "${TEMPDIR}/rootfs.tar"

BASEORIG="$(echo "${BASETARFILE}" |sed -e 's/\.tar$/\.orig\.tar/g')"
cp "${BASETARFILE}" "${BASEORIG}"

echo "I: Append rootfs to base tar..."
tar --concatenate --file="${BASETARFILE}" "${TEMPDIR}/rootfs.tar"

mkdir -p "${TARGET}"


