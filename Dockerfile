# docker build -t probe . && docker run --rm -it probe sh
FROM debian:trixie-slim

RUN <<EOF
set -eux
export DEBIAN_FRONTEND="noninteractive"
apt update
apt upgrade -y
apt install -y --no-install-recommends \
    ca-certificates \
    wget

# https://github.com/RIPE-NCC/ripe-atlas-software-probe/tree/master#debian--raspberry-pi-os
# Download: Debian 11 / 12 / 13 & Raspberry Pi OS 12 / 13
ARCH=$(dpkg --print-architecture)
CODENAME=$(. /etc/os-release && echo "$VERSION_CODENAME")
REPO_PKG=ripe-atlas-repo_1.6-1_all.deb
wget https://ftp.ripe.net/ripe/atlas/software-probe/debian/dists/"$CODENAME"/main/binary-"$ARCH"/"$REPO_PKG" https://github.com/RIPE-NCC/ripe-atlas-software-probe/releases/latest/download/CHECKSUMS
grep -q "$(sha256sum "$REPO_PKG")" CHECKSUMS && echo "Success: checksum matches" || ( printf "\n\033[1;31mError: checksum does not match\033[0m\n\n"; rm "$REPO_PKG" )

# Install: Debian 11 / 12 / 13 & Raspberry Pi OS 12 / 13
dpkg -i "$REPO_PKG" && rm "$REPO_PKG"
apt update
apt install -y --no-install-recommends \
    ripe-atlas-probe

apt autopurge -y
apt distclean -y

echo "RXTXRPT=yes" > /etc/ripe-atlas/config.txt
chown ripe-atlas:ripe-atlas /etc/ripe-atlas/config.txt
rm -rf /etc/ripe-atlas/probe_key*
EOF

USER ripe-atlas
CMD ["/usr/sbin/ripe-atlas"]
