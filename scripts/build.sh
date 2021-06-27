#!/bin/sh
set -e
set -x

SUITE="${1:-bullseye}"
TARGET="$(mktemp --directory build.XXXXXX)"

echo "Building images for '${SUITE}'."
echo "Using '${TARGET}' as target directory."

mkdir -p "${TARGET}"

BASEDIR="$(dirname "$0")"

SCRIPTS="$(find "${BASEDIR}" -type f \! -name build.sh -print)"

export SUITE
export TARGET

for script in ${SCRIPTS}
do
    if [ -x "${script}" ]
    then
        sh "${script}"
    else
        echo "I: Skipping non-executable script '${script}'..."
    fi
done

echo "Done!"
