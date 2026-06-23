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
apt-get install -y linux-image-generic linux-headers-generic initramfs-tools casper dbus systemd-sysv sudo locales nano wget curl git

# Wygeneruj locale
locale-gen en_US.UTF-8
update-locale LANG=en_US.UTF-8

# 2. Instalacja Wayland, ułatwień i menedżera logowania, terminala (kitty), file menedżera (thunar)
apt-get install -y xwayland libwayland-dev wayland-protocols \
    kitty thunar thunar-archive-plugin \
    polkit-kde-agent-1 qtwayland5 qt6-wayland xdg-desktop-portal-hyprland \
    mesa-utils vulkan-tools sddm \
    pavucontrol network-manager network-manager-gnome

# 3. Instalacja narzędzi do zbudowania Hyprland
apt-get install -y cmake meson cpio build-essential g++ pkg-config \
    libdrm-dev libegl-dev libgbm-dev libinput-dev libudev-dev \
    libwayland-dev libxcursor-dev libxkbcommon-dev libseat-dev \
    libxcb1-dev libxcb-render0-dev libxcb-shape0-dev libxcb-xfixes0-dev \
    glslang-tools hwdata jq

# 4. Kompilacja Hyprland (zgodnie z życzeniem ze źródeł)
cd /opt
if [ ! -d "Hyprland" ]; then
    git clone --recursive https://github.com/hyprwm/Hyprland
    cd Hyprland
    make all
    make install
fi

# 5. Instalacja i konfiguracja WINE (uruchamianie .exe)
dpkg --add-architecture i386
apt-get update
apt-get install -y wine64 wine32 wine-binfmt

# Aktualizuj konfigurację mime żeby Wine w Thunar było po dwukliku
mkdir -p /etc/skel/.config
cp /root/config/mimeapps.list /etc/skel/.config/
# Automatyczny skrypt do Wine (czasem przydatny zamiast domyślnego)
cat << 'EOF' > /usr/local/bin/run-exe.sh
#!/bin/bash
wine "$@"
EOF
chmod +x /usr/local/bin/run-exe.sh

# 6. Kopiowanie Themu Hyprland
mkdir -p /etc/skel/.config/hypr
cp /root/config/hyprland.conf /etc/skel/.config/hypr/hyprland.conf

# Do "windows 11 look" pobieramy GTK theme z githuba (Win11 theme od vinceliuice)
apt-get install -y sassc optipng inkscape libglib2.0-dev xmlstarlet
cd /opt
git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git win11-theme
cd win11-theme
./install.sh -c Light -t all -N glassy

# Domyślny theme do ~/.config/gtk-3.0/settings.ini w /etc/skel
mkdir -p /etc/skel/.config/gtk-3.0
cat <<EOF > /etc/skel/.config/gtk-3.0/settings.ini
[Settings]
gtk-theme-name=WhiteSur-Light
gtk-icon-theme-name=WhiteSur
gtk-font-name=Sans 11
gtk-application-prefer-dark-theme=0
EOF

# 7. Utworzenie usera Live
useradd -m -s /bin/bash -G sudo,video,audio,plugdev,netdev live
echo "live:live" | chpasswd
echo "live ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# SDDM Auto-login
mkdir -p /etc/sddm.conf.d
cat <<EOF > /etc/sddm.conf.d/autologin.conf
[Autologin]
User=live
Session=hyprland
EOF

# Czyszczenie na koniec
apt-get clean
rm -rf /var/lib/apt/lists/*
rm -rf /tmp/*

# Wygeneruj ostateczny Initramfs
update-initramfs -u
