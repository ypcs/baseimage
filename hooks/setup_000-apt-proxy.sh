#!/bin/sh
set -e

mkdir -p "$1/etc/apt/apt.conf.d"

if [ -n "${APT_PROXY}" ]
then
cat > "$1/etc/apt/apt.conf.d/99proxy" << EOF
Acquire::HTTP::Proxy "${APT_PROXY}";
EOF
fi
