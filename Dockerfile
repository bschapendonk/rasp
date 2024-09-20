# export BUILDKIT_PROGRESS=plain
# docker build -t probe . && docker run --rm -it probe
FROM alpine AS builder

RUN <<EOF
adduser -D -H probe probe

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

git clone --recursive https://github.com/RIPE-NCC/ripe-atlas-software-probe.git /tmp/probe

cd /tmp/probe

autoreconf -iv

./configure \
    --prefix=/probe \
    --with-user=probe \
    --with-group=probe \
    --disable-systemd

# FIX: make tries to chown this file, but it doesnt exist yet
mkdir -p /probe/etc/ripe-atlas
touch /probe/etc/ripe-atlas/mode

make install
EOF

COPY --chown=probe:probe --chmod=0755 <<EOF /probe/start
#!/bin/sh
if [ -f etc/ripe-atlas/probe_key ]; then
    chmod 0600 etc/ripe-atlas/probe_key
fi
if [ -f etc/ripe-atlas/probe_key.pub ]; then
    chmod 0644 etc/ripe-atlas/probe_key.pub
fi
sbin/ripe-atlas
EOF

FROM alpine

RUN <<EOF
adduser -D -H probe probe

apk add --upgrade --no-cache \
    libcap \
    net-tools \
    openssh-client
EOF

COPY --from=builder --chown=probe:probe /probe /probe

WORKDIR /probe
USER probe
CMD ["/probe/start"]
