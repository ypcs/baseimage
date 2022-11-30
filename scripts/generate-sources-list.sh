#!/bin/sh
set -e

#
# Generate sources.list for specific Debian or Ubuntu suite
#
# usage:
#
#     ./generate-sources-list.sh <suite>
#
# eg.
#
#     ./generate-sources-list.sh bionic
#

# Import list of supported suites
. "$(dirname "$0")/../config"

SUITE="$1"

set +e
echo "${DEBIAN_SUITES}" |grep -qE "(^${SUITE}$| ${SUITE}$| ${SUITE} |^${SUITE} )"
DEBIAN="$?"
echo "${UBUNTU_SUITES}" |grep -qE "(^${SUITE}$| ${SUITE}$| ${SUITE} |^${SUITE} )"
UBUNTU="$?"
set -e

if [ "${DEBIAN}" = "0" ]
then
  DISTRO="debian"
elif [ "${UBUNTU}" = "0" ]
then
  DISTRO="ubuntu"
fi

case "${DISTRO}"
in
  debian)
    ARCHIVE_MIRROR="http://deb.debian.org/debian"
    cat << EOF
deb ${ARCHIVE_MIRROR} ${SUITE} main
#deb-src ${ARCHIVE_MIRROR} ${SUITE} main
EOF
    if [ "${SUITE}" != "sid" ]
    then
    cat << EOF
deb ${ARCHIVE_MIRROR} ${SUITE}-updates main
#deb-src ${ARCHIVE_MIRROR} ${SUITE}-updates main

deb ${ARCHIVE_MIRROR}-security ${SUITE}-security main contrib non-free
#deb-src ${ARCHIVE_MIRROR}-security ${SUITE}-security main contrib non-free
EOF
    fi
  ;;
  ubuntu)
    ARCHIVE_MIRROR="http://archive.ubuntu.com/ubuntu"
    cat << EOF
deb ${ARCHIVE_MIRROR} ${SUITE} main
#deb-src ${ARCHIVE_MIRROR} ${SUITE} main

deb ${ARCHIVE_MIRROR} ${SUITE}-updates main
#deb-src ${ARCHIVE_MIRROR} ${SUITE}-updates main

#deb ${ARCHIVE_MIRROR} ${SUITE}-backports main
#deb-src ${ARCHIVE_MIRROR} ${SUITE}-backports main

deb ${ARCHIVE_MIRROR} ${SUITE}-security main
#deb-src ${ARCHIVE_MIRROR} ${SUITE}-security main
EOF
  ;;
  *)
    echo 1>&2 "ERROR: Unknown or unset suite: '${SUITE}'."
    exit 1
    ;;
esac
