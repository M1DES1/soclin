#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

sudo_do() {
    sudo "$@"
}

echo "[github] Installing host dependencies..."
sudo_do apt-get update
sudo_do apt-get install -y \
    live-build \
    debootstrap \
    squashfs-tools \
    xorriso \
    grub-pc-bin \
    grub-efi-amd64-bin \
    mtools \
    dosfstools \
    rsync \
    wget \
    curl \
    git \
    ca-certificates \
    gnupg2 \
    jq \
    software-properties-common \
    apt-transport-https \
    make \
    gettext \
    dpkg-dev \
    po4a \
    debian-archive-keyring

chmod +x ./auto/config ./build.sh
find ./config/hooks -type f -name '*.chroot' -exec chmod +x {} \;
find ./config/includes.chroot -type f -name '*.sh' -exec chmod +x {} \; 2>/dev/null || true

# CI build should stay on Ubuntu sources only until Debian archive usage is fixed.
rm -f ./config/archives/debian.list.chroot

sudo_do lb clean --purge || true
./auto/config
sudo_do lb build
