#!/bin/sh
set -e
set -x

[ -z "${TARGET}" ] && echo "Variable \$TARGET not set!" >&2 && exit 1
[ -z "${SUITE}" ] && echo "Variable \$SUITE not set!" >&2 && exit 1

if [ ! -x /usr/bin/mmdebstrap ]
then
    echo "mmdebstrap binary not found!" >&2
    exit 1
fi

echo "I: Build base image with $(/usr/bin/mmdebstrap --version)..."
/usr/bin/mmdebstrap \
    --architecture="${ARCH:-amd64}" \
    --format=tar \
    --hook-directory="${TARGET}/hooks" \
    --mode=fakechroot \
    --variant=minbase \
    --verbose \
    "${SUITE}" \
    "${TARGET}/${SUITE}.base.tar" 2>&1|tee "${TARGET}/${SUITE}.mmdebstrap.log"
