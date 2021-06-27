#!/bin/sh
set -e

[ -z "${TARGET}" ] && echo "Variable \$TARGET not set!" >&2 && exit 1

echo "FIXME!"
mkdir -p "${TARGET}/hooks"
