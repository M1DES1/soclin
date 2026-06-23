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

# 2. Instalacja absolutnego minimum z GUI i prawdziwego instalatora live.
apt-get install -y xserver-xorg xinit openbox sddm calamares calamares-settings-ubuntu-common \
    xserver-xorg-video-fbdev xserver-xorg-video-vesa \
    pavucontrol network-manager-gnome virtualbox-guest-x11 virtualbox-guest-utils

# Kopiowanie motywu Hyprland do użytku po instalacji
mkdir -p /etc/skel/.config/hypr
cp /root/config/hypr/hyprland.conf /etc/skel/.config/hypr/hyprland.conf
cp /root/config/mimeapps.list /etc/skel/.config/

# Instalator Calamares i branding
mkdir -p /etc/calamares/branding/winux /etc/calamares/modules
cp -r /root/config/calamares/branding/winux/. /etc/calamares/branding/winux/
cp -r /root/config/calamares/modules/. /etc/calamares/modules/
cp /root/config/calamares/settings.conf /etc/calamares/settings.conf

cat <<'EOF' > /usr/local/bin/winux-launch-installer
#!/bin/bash
set -e
sleep 2
if pgrep -x calamares >/dev/null; then
    exit 0
fi
exec calamares --fullscreen
EOF
chmod +x /usr/local/bin/winux-launch-installer

# Openbox Autostart (odpala pełny instalator przy pierwszym włączeniu live)
mkdir -p /etc/skel/.config/openbox
cat <<EOF > /etc/skel/.config/openbox/autostart
# Uruchom instalator w sesji live bez pokazywania technicznego konta "live".
/usr/local/bin/winux-launch-installer &
EOF

mkdir -p /etc/skel/Desktop
cat <<'EOF' > /etc/skel/Desktop/Install-Winux.desktop
[Desktop Entry]
Type=Application
Name=Install Winux OS
Comment=Launch the Winux OS installer
Exec=/usr/local/bin/winux-launch-installer
Icon=system-software-install
Terminal=false
Categories=System;
EOF
chmod +x /etc/skel/Desktop/Install-Winux.desktop

# 7. Utworzenie technicznego usera Live dla sesji instalatora
useradd -m -s /bin/bash -G sudo,video,audio,plugdev,netdev live
echo "live:live" | chpasswd
echo "live ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# SDDM Auto-login do Openbox
mkdir -p /etc/sddm.conf.d
cat <<EOF > /etc/sddm.conf.d/display.conf
[General]
DisplayServer=x11
EOF
cat <<EOF > /etc/sddm.conf.d/autologin.conf
[Autologin]
User=live
Session=openbox.desktop
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
