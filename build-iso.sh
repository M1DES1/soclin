#!/bin/bash
set -ex

# Zmienne środowiskowe
export DEBIAN_FRONTEND=noninteractive
export ISO_NAME="soclin"
export WORKDIR="$(pwd)/iso_build"
export ROOTFS="$WORKDIR/chroot"
export ISO_DIR="$WORKDIR/iso"
export DATE=$(date +%Y%m%d)

# 1. Przygotowanie folderów
rm -rf "$WORKDIR"
mkdir -p "$ROOTFS"
mkdir -p "$ISO_DIR/casper"
mkdir -p "$ISO_DIR/boot/grub"

# 2. Budowa bazowego systemu (Ubuntu Noble 24.04)
echo "=== Instalowanie bazowego systemu Noble ==="
debootstrap --arch=amd64 noble "$ROOTFS" http://archive.ubuntu.com/ubuntu/

# Zamontowanie systemów plików wewnątrz chroot
mount --bind /dev "$ROOTFS/dev"
mount -t proc proc "$ROOTFS/proc"
mount -t sysfs sysfs "$ROOTFS/sys"
mount -t devpts devpts "$ROOTFS/dev/pts"

# 3. Kopiowanie skryptu instalacyjnego i konfiguracji do chroot
cp chroot-setup.sh "$ROOTFS/root/"
chmod +x "$ROOTFS/root/chroot-setup.sh"
cp -r config "$ROOTFS/root/"

# Skopiowanie repo soclin do ewentualnych źródeł (opcjonalne)
# cp -r . "$ROOTFS/root/soclin-repo"

echo "=== Uruchamianie chroot-setup.sh ==="
chroot "$ROOTFS" /bin/bash /root/chroot-setup.sh

# Sprzątanie wewnątrz
rm -rf "$ROOTFS/root/chroot-setup.sh" "$ROOTFS/root/config"

# Odmontowanie
umount "$ROOTFS/dev/pts"
umount "$ROOTFS/sys"
umount "$ROOTFS/proc"
umount "$ROOTFS/dev"

# 4. Kernel i Initrd
echo "=== Przygotowanie bootowania ==="
cp "$ROOTFS/boot/vmlinuz-"* "$ISO_DIR/boot/vmlinuz" || cp "$ROOTFS/boot/vmlinuz" "$ISO_DIR/boot/vmlinuz"
cp "$ROOTFS/boot/initrd.img-"* "$ISO_DIR/boot/initrd.img" || cp "$ROOTFS/boot/initrd.img" "$ISO_DIR/boot/initrd.img"

# 5. Generowanie SquashFS
echo "=== Kompresja do SquashFS ==="
mksquashfs "$ROOTFS" "$ISO_DIR/casper/filesystem.squashfs" -comp xz -wildcards -e boot/vmlinuz* boot/initrd.img*

sleep 2
printf $(du -sx --block-size=1 "$ROOTFS" | cut -f1) > "$ISO_DIR/casper/filesystem.size"

# 6. GRUB config
cat <<EOF > "$ISO_DIR/boot/grub/grub.cfg"
set default="0"
set timeout=5
menuentry "soclin" {
    linux /boot/vmlinuz boot=casper username=live hostname=soclin quiet splash ---
    initrd /boot/initrd.img
}
menuentry "soclin (Safe Graphics)" {
    linux /boot/vmlinuz boot=casper nomodeset username=live hostname=soclin quiet splash ---
    initrd /boot/initrd.img
}
EOF

# 7. Budowanie pliku ISO za pomocą xorriso-dd-target / grub-mkrescue
echo "=== Generowanie pliku ISO ==="
(cd "$ISO_DIR" && find . -type f -not -name md5sum.txt -print0 | xargs -0 md5sum > md5sum.txt)
grub-mkrescue -o "${ISO_NAME}-${DATE}.iso" "$ISO_DIR"

echo "=== Gotowe: ${ISO_NAME}-${DATE}.iso ==="
