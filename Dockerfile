# docker build -t probe . && docker run --rm -it probe sh
FROM debian:trixie-slim

RUN <<EOF
set -eux
useradd -m rasp

export DEBIAN_FRONTEND="noninteractive"
apt update
apt upgrade -y
apt install -y --no-install-recommends \
    ca-certificates \
    curl

curl -sL -o /etc/apt/trusted.gpg.d/ripe-atlas.asc https://raw.githubusercontent.com/RIPE-NCC/ripe-atlas-software-probe/refs/heads/master/.repo/RPM-GPG-KEY-ripe-atlas-20240924.master

. /etc/os-release
cat << CAT_EOF > /etc/apt/sources.list.d/ripe-atlas.sources
Types: deb
URIs: https://ftp.ripe.net/ripe/atlas/software-probe/debian
Suites: $VERSION_CODENAME
Components: main
Signed-By: /etc/apt/trusted.gpg.d/ripe-atlas.asc
CAT_EOF

apt update
apt install -y --no-install-recommends \
    ripe-atlas-probe

apt autopurge -y
apt distclean -y

echo "RXTXRPT=yes" > /etc/ripe-atlas/config.txt
chown ripe-atlas:ripe-atlas /etc/ripe-atlas/config.txt
chmod -R 600 /etc/ripe-atlas
rm -rf /etc/ripe-atlas/probe_key*
EOF

# USER ripe-atlas
# CMD ["/usr/sbin/ripe-atlas"]
