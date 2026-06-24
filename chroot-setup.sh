#!/bin/bash
set -ex

# Ten skrypt działa w środowisku root chroot
export DEBIAN_FRONTEND=noninteractive

# W chroot nie chcemy uruchamiać usług z postinst, bo generują fałszywe błędy
# i potrafią dociągać dodatkowe elementy sesji desktopowej.
cat <<'EOF' > /usr/sbin/policy-rc.d
#!/bin/sh
exit 101
EOF
chmod +x /usr/sbin/policy-rc.d

# Ustawienie repozytoriów
cat <<EOF > /etc/apt/sources.list
deb http://archive.ubuntu.com/ubuntu/ noble main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu/ noble-updates main restricted universe multiverse
deb http://security.ubuntu.com/ubuntu/ noble-security main restricted universe multiverse
EOF

apt-get update
apt-get upgrade -y

# 1. Instalacja podstawowych pakietów środowiska i kernela
apt-get install -y --no-install-recommends linux-image-generic linux-headers-generic initramfs-tools casper sudo \
    locales nano wget curl git dbus systemd-sysv network-manager plymouth plymouth-label

locale-gen en_US.UTF-8
update-locale LANG=en_US.UTF-8

# 2. Instalacja absolutnego minimum z GUI i prawdziwego instalatora live.
apt-get install -y --no-install-recommends xserver-xorg xinit openbox sddm calamares calamares-settings-ubuntu-common \
    xserver-xorg-video-fbdev xserver-xorg-video-vesa \
    pavucontrol network-manager-gnome virtualbox-guest-x11 virtualbox-guest-utils

# Branding systemu bazowego
cat <<EOF > /etc/os-release
PRETTY_NAME="soclin"
NAME="soclin"
VERSION_ID="24.04"
VERSION="24.04"
VERSION_CODENAME=noble
ID=soclin
ID_LIKE=ubuntu
HOME_URL="https://soclin.local/"
SUPPORT_URL="https://soclin.local/"
BUG_REPORT_URL="https://soclin.local/"
PRIVACY_POLICY_URL="https://soclin.local/"
UBUNTU_CODENAME=noble
LOGO=distributor-logo
EOF
if [ ! /etc/os-release -ef /usr/lib/os-release ]; then
    cp /etc/os-release /usr/lib/os-release
fi
cat <<EOF > /etc/lsb-release
DISTRIB_ID=soclin
DISTRIB_RELEASE=24.04
DISTRIB_CODENAME=noble
DISTRIB_DESCRIPTION="soclin"
EOF

# Kopiowanie motywu Hyprland do użytku po instalacji
mkdir -p /etc/skel/.config/hypr
cp /root/config/hypr/hyprland.conf /etc/skel/.config/hypr/hyprland.conf
cp /root/config/mimeapps.list /etc/skel/.config/

# Instalator Calamares i branding
mkdir -p /etc/calamares/branding/soclin /etc/calamares/modules
cp -r /root/config/calamares/branding/soclin/. /etc/calamares/branding/soclin/
cp -r /root/config/calamares/modules/. /etc/calamares/modules/
cp /root/config/calamares/settings.conf /etc/calamares/settings.conf

# Customowy splash bootowania
mkdir -p /usr/share/plymouth/themes/soclin
cp -r /root/config/plymouth/. /usr/share/plymouth/themes/soclin/
update-alternatives --install /usr/share/plymouth/themes/default.plymouth default.plymouth /usr/share/plymouth/themes/soclin/soclin.plymouth 100
update-alternatives --set default.plymouth /usr/share/plymouth/themes/soclin/soclin.plymouth

cat <<'EOF' > /usr/local/bin/soclin-launch-installer
#!/bin/bash
set -e
sleep 2
if pgrep -x calamares >/dev/null; then
    exit 0
fi
exec calamares --fullscreen
EOF
chmod +x /usr/local/bin/soclin-launch-installer

# 7. Utworzenie technicznego usera Live dla sesji instalatora
for grp in plugdev netdev; do
    getent group "$grp" >/dev/null || groupadd "$grp"
done
useradd -m -s /bin/bash -G sudo,video,audio,plugdev,netdev live
echo "live:live" | chpasswd
cat <<EOF > /etc/sudoers.d/live-nopasswd
live ALL=(ALL) NOPASSWD: ALL
EOF
chmod 440 /etc/sudoers.d/live-nopasswd

# Live start bez menedzera logowania: getty -> autologin -> startx -> openbox -> calamares
mkdir -p /etc/systemd/system/getty@tty1.service.d
cat <<EOF > /etc/systemd/system/getty@tty1.service.d/autologin.conf
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin live --noclear %I \$TERM
Type=simple
EOF
systemctl disable sddm || true
rm -f /etc/systemd/system/display-manager.service

mkdir -p /home/live/.config/openbox /home/live/Desktop
cat <<'EOF' > /home/live/.config/openbox/autostart
/usr/local/bin/soclin-launch-installer &
EOF
cat <<'EOF' > /home/live/.xinitrc
#!/bin/sh
exec openbox-session
EOF
cat <<'EOF' > /home/live/.bash_profile
if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
    exec startx
fi
EOF
cat <<'EOF' > /home/live/Desktop/Install-soclin.desktop
[Desktop Entry]
Type=Application
Name=Install soclin
Comment=Launch the soclin installer
Exec=/usr/local/bin/soclin-launch-installer
Icon=system-software-install
Terminal=false
Categories=System;
EOF
chmod +x /home/live/.xinitrc /home/live/Desktop/Install-soclin.desktop
chown -R live:live /home/live

# Wyłączenie sprawdzania sum kontrolnych na starcie (psuje boot customowego ISO)
rm -f /usr/lib/systemd/system/casper-md5check.service
rm -f /etc/systemd/system/multi-user.target.wants/casper-md5check.service

# Czyszczenie na koniec ISO buildu
rm -f /usr/sbin/policy-rc.d
apt-get clean
rm -rf /var/lib/apt/lists/*
rm -rf /tmp/*

update-initramfs -u
