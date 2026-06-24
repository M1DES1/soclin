#!/bin/bash

zenity --info --title="soclin Installer" --text="Rozpoczynam instalację Hyprland, motywów Windows 11 i środowiska Wine. \n\nProszę czekać, może to potrwać kilkanaście minut na połączenie z internetem i pobieranie paczek." --width=400

# Włączenie repozytoriów jeżeli system działa z RAMu
apt-get update

# Instalacja pełnych zależności Wayland 
apt-get install -y meson cpio build-essential g++ pkg-config \
    libdrm-dev libegl-dev libegl1-mesa-dev libgles2-mesa-dev libgl1-mesa-dev \
    libgbm-dev libinput-dev libudev-dev libwayland-dev libxcursor-dev \
    libxkbcommon-dev libseat-dev libxcb1-dev libxcb-render0-dev \
    libxcb-shape0-dev libxcb-xfixes0-dev libvulkan-dev \
    glslang-tools glslang-dev libglslang-dev libdisplay-info-dev \
    libhwdata-dev libpixman-1-dev uuid-dev libffi-dev ninja-build \
    libxcb-composite0-dev libxcb-present-dev libxcb-dri3-dev libxcb-res0-dev \
    libx11-xcb-dev hwdata jq thunar thunar-archive-plugin \
    wine64 wine32 wine-binfmt xdg-desktop-portal-wlr qtwayland5 qt6-wayland xwayland

# Ręczna instalacja wymaganego CMake 3.31
cd /tmp
wget https://github.com/Kitware/CMake/releases/download/v3.31.4/cmake-3.31.4-linux-x86_64.tar.gz
tar -zxvf cmake-3.31.4-linux-x86_64.tar.gz -C /usr/local --strip-components=1
rm cmake-3.31.4-linux-x86_64.tar.gz

# Pobieranie i kompilacja Hyprland
cd /opt
if [ ! -d "Hyprland" ]; then
    git clone --recursive https://github.com/hyprwm/Hyprland
    cd Hyprland
    make all
    make install
fi

# Instalacja Win11 Theme
apt-get install -y sassc optipng inkscape libglib2.0-dev xmlstarlet
cd /opt
if [ ! -d "win11-theme" ]; then
    git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git win11-theme
    cd win11-theme
    ./install.sh -c Light -t all -N glassy
fi

# Logowanie ma pozostać normalne, bez automatycznego wejścia do sesji.
mkdir -p /etc/sddm.conf.d
rm -f /etc/sddm.conf.d/autologin.conf

mkdir -p /home/live/.config/gtk-3.0
cat <<EOF > /home/live/.config/gtk-3.0/settings.ini
[Settings]
gtk-theme-name=WhiteSur-Light
gtk-icon-theme-name=WhiteSur
gtk-font-name=Sans 11
gtk-application-prefer-dark-theme=0
EOF
chown -R live:live /home/live/.config/

# Konfiguracja otwierania i integracji .exe dla Wine
cp /home/live/.config/mimeapps.list /etc/skel/.config/ 2>/dev/null || true
mkdir -p /home/live/.local/share/applications
# Desktop app do otworzenia wine
cat <<EOF > /home/live/.local/share/applications/wine.desktop
[Desktop Entry]
Name=Wine Windows Program Loader
Exec=wine start /unix %f
Type=Application
StartupNotify=true
Path=/tmp
Icon=wine
Categories=X-Wine;
MimeType=application/x-ms-dos-executable;application/x-msi;application/x-ms-shortcut;
NoDisplay=true
EOF
chown -R live:live /home/live/.local/

zenity --info --title="Instalacja Zakończona" --text="System soclin z Hyprland jest gotowy. \n\nInstalator uruchomi system ponownie by odpalić środowisko soclin." --width=400

# Zrestartuj aby wbiło menedżera logowania bezposródnio do Hyprland
reboot
