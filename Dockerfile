# export BUILDKIT_PROGRESS=plain
# docker build -t probe . && docker run --rm -it probe
FROM --platform=$BUILDPLATFORM alpine AS builder

RUN <<EOF
adduser -D -H rasp rasp

apk add --upgrade --no-cache \
    autoconf \
    automake \
    g++ \
    gcc \
    git \
    libcap \
    libtool \
    linux-headers \
    make \
    openssl-dev

git clone --recursive https://github.com/RIPE-NCC/ripe-atlas-software-probe.git /tmp/rasp

cd /tmp/rasp

autoreconf -iv

./configure \
    --prefix=/rasp \
    --with-user=rasp \
    --with-group=rasp \
    --disable-systemd

# FIX: make tries to chown this file, but it doesnt exist yet
mkdir -p /rasp/etc/ripe-atlas
touch /rasp/etc/ripe-atlas/mode

make install

echo "RXTXRPT=yes" > /rasp/etc/ripe-atlas/config.txt
EOF

FROM alpine

RUN <<EOF
adduser -D -H rasp rasp

apk add --upgrade --no-cache \
    net-tools \
    openssh-client
EOF

COPY --from=builder --chown=rasp:rasp /rasp /rasp

USER rasp
CMD ["/rasp/sbin/ripe-atlas"]
