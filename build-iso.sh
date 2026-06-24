#!/bin/bash
set -euo pipefail

# Budujemy proste ISO, które bootuje bezpośrednio do oficjalnego
# graficznego Debian Installer, bez sesji live i bez Calamares.
export DEBIAN_FRONTEND=noninteractive
export ISO_NAME="soclin-debian-installer"
export WORKDIR="$(pwd)/iso_build"
export ISO_DIR="$WORKDIR/iso"
export DATE
DATE="$(date +%Y%m%d)"

export DEBIAN_SUITE="${DEBIAN_SUITE:-stable}"
export DEBIAN_MIRROR="${DEBIAN_MIRROR:-https://deb.debian.org/debian}"
export INSTALLER_BASE="${DEBIAN_MIRROR}/dists/${DEBIAN_SUITE}/main/installer-amd64/current/images/netboot/gtk/debian-installer/amd64"

rm -rf "$WORKDIR"
mkdir -p "$ISO_DIR/boot/grub" "$ISO_DIR/install.amd"

echo "=== Pobieranie Debian Installer (${DEBIAN_SUITE}) ==="
wget -qO "$ISO_DIR/install.amd/linux" "${INSTALLER_BASE}/linux"
wget -qO "$ISO_DIR/install.amd/initrd.gz" "${INSTALLER_BASE}/initrd.gz"

cat <<'EOF' > "$ISO_DIR/boot/grub/grub.cfg"
set default=0
set timeout=0
set timeout_style=hidden

menuentry "soclin Debian Installer" {
    linux /install.amd/linux auto=true priority=medium language=pl country=PL locale=pl_PL.UTF-8 keyboard-configuration/xkb-keymap=pl hostname=soclin domain=local quiet ---
    initrd /install.amd/initrd.gz
}

menuentry "soclin Debian Installer (safe graphics)" {
    linux /install.amd/linux auto=true priority=medium language=pl country=PL locale=pl_PL.UTF-8 keyboard-configuration/xkb-keymap=pl hostname=soclin domain=local nomodeset quiet ---
    initrd /install.amd/initrd.gz
}
EOF

echo "=== Generowanie sum kontrolnych ==="
(cd "$ISO_DIR" && find . -type f -not -name md5sum.txt -print0 | xargs -0 md5sum > md5sum.txt)

echo "=== Budowanie ISO ==="
grub-mkrescue -o "${ISO_NAME}-${DATE}.iso" "$ISO_DIR"

echo "=== Gotowe: ${ISO_NAME}-${DATE}.iso ==="
