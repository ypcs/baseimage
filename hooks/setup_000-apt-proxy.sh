#!/bin/sh
set -e

mkdir -p "$1/etc/apt/apt.conf.d"

cat > "$1/etc/apt/apt.conf.d/99proxy" << EOF
Acquire::HTTP::Proxy "http://127.0.0.1:3142";
EOF
