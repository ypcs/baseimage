#!/bin/bash
set -e
set -u
set -o pipefail

#
# Build images for various platforms
#
# <https://ypcs.fi/baseimage/>
# Copyright 2021 Ville Korhonen <ville@xd.fi>
#

BASEDIR="$(dirname "$0")"

# Target directory for build artifacts
BUILD_DIR="build"

# Identifier for semaphore
SEM_ID="baseimage-mmdebstrap"

# Set sane defaults
MAX_CPUS="+0"

# Read configuration
if [ -f "${BASEDIR}/config/build" ]
then
    echo "I: Read configuration from '${BASEDIR}/config/build'."
    . "${BASEDIR}/config/build"
fi

# Ensure target directory exists
mkdir -p "${BUILD_DIR}"

# Create temporary directory
TEMPDIR="${BUILD_DIR}/temp"
echo "D: Using temporary directory '${TEMPDIR}'..."

MMDEBSTRAP_VERSION="$(mmdebstrap --version)"

# Loop through all configured architectures
for arch in "${BASEDIR}"/architectures/*
do
    ARCH="$(basename "${arch}")"

    # Loop through all configured distributions
    for dist in "${BASEDIR}"/distributions/*
    do
        DIST="$(basename "${dist}")"

        # Loop through all releases for given distribution
        for release in "${dist}"/* 
        do
            RELEASE="$(basename "${release}")"

            # Loop through all platforms
            for platform in "${BASEDIR}"/platforms/*
            do
                PLATFORM="$(basename "${platform}")"
                TARGET="${DIST}-${RELEASE}_${ARCH}_${PLATFORM}"
                TARGET_PATH="${BUILD_DIR}/${TARGET}"
                TARGET_FILE="${TARGET_PATH}.tar"
                TARGET_TMP="${TEMPDIR}/${TARGET}"
                mkdir -p "${TARGET_TMP}"
                echo "I: Build target: ${TARGET} => ${TARGET_FILE}"

                # Merge arch/dist/release/platform-specific config
                for item in hooks rootfs
                do
                    ITEMS="${item} ${arch}/${item} ${dist}/${item} ${release}/${item} ${platform}/${item}"
                    for itm in ${ITEMS}
                    do
                        if [ -e "${itm}" ]
                        then
                            cp -a "${itm}/" "${TARGET_TMP}/" 2>/dev/null || true
                        fi
                    done
                done

                # Store build configuration for this build
                tar --directory="${TARGET_TMP}" -cf "${TARGET_PATH}.config.tar" .

                # Construct the build command
                COMMAND="/usr/bin/mmdebstrap --architecture='${ARCH}' --format=tar --hook-directory='${TARGET_TMP}/hooks' --logfile='${BUILD_DIR}/${TARGET}.log' --mode=fakechroot --variant=minbase --verbose '${RELEASE}' '${TARGET_FILE}' && tar --directory '${TARGET_TMP}/rootfs' -rf '${TARGET_FILE}' ."

                # Keep full command to make build repeatable
                echo "# Build with ${MMDEBSTRAP_VERSION}" > "${TARGET_PATH}.cmdline"
                echo "${COMMAND}" >> "${TARGET_PATH}.cmdline"

                # Schedule the build job
                sem \
                    --id="${SEM_ID}" \
                    --jobs "${MAX_CPUS}" \
                    "${COMMAND}"
            done
        done
    done
done
echo "I: Waiting for builds to finish..."
sem --wait --id "${SEM_ID}"
