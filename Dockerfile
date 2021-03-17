FROM docker.io/ypcs/debian:bullseye

ARG APT_PROXY

RUN /usr/lib/baseimage-helpers/apt-setup && \
    /usr/lib/baseimage-helpers/apt-upgrade && \
    apt-get --assume-yes install \
        mmdebstrap \
        parallel \
        xz-utils && \
    /usr/lib/baseimage-helpers/apt-cleanup

# GNU Parallel asks you to use correct citation if you use it to produce
# scientific papers. However, this also breaks automation => let's skip that
# question. Please see `man parallel`.
RUN parallel --will-cite

COPY . /opt/baseimage/

CMD ["/bin/bash", "/opt/baseimage/build.sh"]
