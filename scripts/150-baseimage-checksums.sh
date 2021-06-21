#!/bin/sh
set -e

tar xvf \
    "${TARGET}/${SUITE}.base.tar" \
    --to-command sha256sum |tee "${TARGET}/${SUITE}.base.tar.sha256sums"
