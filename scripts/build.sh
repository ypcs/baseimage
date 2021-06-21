#!/bin/sh
set -e
set -x

SUITE="${1:-bullseye}"
TARGET="build"

mkdir -p "${TARGET}"

BASEDIR="$(dirname "$0")"

SCRIPTS="$(find "${BASEDIR}" -type f \! -name build.sh -print)"

export SUITE
export TARGET

for script in ${SCRIPTS}
do
    sh "${script}"
done

echo "Done!"
