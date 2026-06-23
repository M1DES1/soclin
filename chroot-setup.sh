#!/bin/bash
set -ex

# Ten skrypt działa w środowisku root chroot
export DEBIAN_FRONTEND=noninteractive

# Ustawienie repozytoriów
cat <<EOF > /etc/apt/sources.list
deb http://archive.ubuntu.com/ubuntu/ noble main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu/ noble-updates main restricted universe multiverse
deb http://security.ubuntu.com/ubuntu/ noble-security main restricted universe multiverse
EOF

apt-get update
apt-get upgrade -y

# 1. Instalacja podstawowych pakietów środowiska i kernela
apt-get install -y linux-image-generic linux-headers-generic initramfs-tools casper sudo \
    locales nano wget curl git dbus systemd-sysv network-manager

locale-gen en_US.UTF-8
update-locale LANG=en_US.UTF-8

# 2. Instalacja absolutnego minimum z GUI, żeby pokazać okno instalacji po zbotowaniu
# Użyjemy Openbox i Kitty. Zenity pomoże pokazać okienko powitalne.
apt-get install -y xserver-xorg xinit openbox kitty zenity sddm \
    pavucontrol network-manager-gnome virtualbox-guest-x11 virtualbox-guest-utils

# Kopiowanie motywu Hyprland do użytku po instalacji
mkdir -p /etc/skel/.config/hypr
cp /root/config/hypr/hyprland.conf /etc/skel/.config/hypr/hyprland.conf
cp /root/config/mimeapps.list /etc/skel/.config/

# Iniekcja Skryptu Instalacyjnego do autostartu
cp /root/config/winux-setup.sh /usr/local/bin/winux-setup.sh
chmod +x /usr/local/bin/winux-setup.sh

# Openbox Autostart (odpala okienko przy pierwszym włączeniu live)
mkdir -p /etc/skel/.config/openbox
cat <<EOF > /etc/skel/.config/openbox/autostart
# Odpal instalator w terminalu, żeby użytkownik widział postęp
kitty -e sudo bash /usr/local/bin/winux-setup.sh &
EOF

# 7. Utworzenie usera Live
useradd -m -s /bin/bash -G sudo,video,audio,plugdev,netdev live
echo "live:live" | chpasswd
echo "live ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# SDDM Auto-login do Openbox
mkdir -p /etc/sddm.conf.d
cat <<EOF > /etc/sddm.conf.d/autologin.conf
[Autologin]
User=live
Session=openbox
EOF
systemctl disable gdm3 || true
ln -sf /lib/systemd/system/sddm.service /etc/systemd/system/display-manager.service
systemctl enable sddm

# Wyłączenie sprawdzania sum kontrolnych na starcie (psuje boot customowego ISO)
rm -f /usr/lib/systemd/system/casper-md5check.service
rm -f /etc/systemd/system/multi-user.target.wants/casper-md5check.service

# Czyszczenie na koniec ISO buildu
apt-get clean
rm -rf /var/lib/apt/lists/*
rm -rf /tmp/*

update-initramfs -u
