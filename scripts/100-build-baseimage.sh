#!/bin/sh
set -e
set -x

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
