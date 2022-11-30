FROM scratch
ARG UBUNTU_SUITE

LABEL org.opencontainers.image.description "Ubuntu ${UBUNTU_SUITE} basebox by Seravo.com"

ADD "${UBUNTU_SUITE}.rootfs.tar" /
