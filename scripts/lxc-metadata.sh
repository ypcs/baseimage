#!/bin/sh
set -e

DISTRIBUTION="$1"
RELEASE="$2"

[ -z "${DISTRIBUTION}" ] && exit 1

if [ -z "${RELEASE}" ]
then
    TMP="${DISTRIBUTION}"
    DISTRIBUTION="$(echo "${TMP}" |cut -d'-' -f1)"
    RELEASE="$(echo "${TMP}" |cut -d'-' -f2)"
fi

[ -z "${RELEASE}" ] && exit 1

echo "Generate LXC metadata: ${DISTRIBUTION} ${RELEASE}"

TEMPDIR="$(mktemp --tmpdir --directory lxc-metadata.XXXXXX)"

cat > "${TEMPDIR}/metadata.yaml" << EOF
architecture: "x86_64"
creation_date: $(date +%s)
properties:
architecture: "x86_64"
description: "${DISTRIBUTION} ${RELEASE} ($(date +%Y%m%d))"
os: "${DISTRIBUTION}"
release: "${RELEASE}"
EOF

tar -C "${TEMPDIR}" -cvzf "${DISTRIBUTION}-${RELEASE}_metadata.tar.gz" metadata.yaml
