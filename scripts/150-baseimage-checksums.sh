#!/bin/sh
set -e

[ -z "${TARGET}" ] && echo "Variable \$TARGET not set!" >&2 && exit 1
[ -z "${SUITE}" ] && echo "Variable \$SUITE not set!" >&2 && exit 1

tar xvf \
    "${TARGET}/${SUITE}.base.tar" \
    --to-command sha256sum |tee "${TARGET}/${SUITE}.base.tar.sha256sums"
