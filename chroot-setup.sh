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
    locales nano wget curl git dbus systemd-sysv network-manager plymouth plymouth-label rsync squashfs-tools

locale-gen en_US.UTF-8
update-locale LANG=en_US.UTF-8

# 2. Instalacja minimalnego środowiska live dla sesji instalatora.
# Pakiety video/input są dodane jawnie, bo `--no-install-recommends` potrafi
# zostawić zbyt okrojony X.Org i wtedy display manager nie wstaje.
apt-get install -y --no-install-recommends xserver-xorg xserver-xorg-video-all xserver-xorg-input-all \
    xinit x11-xserver-utils dbus-x11 openbox sddm calamares calamares-settings-ubuntu-common \
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
#region debug-point live-installer-start
{
    echo "==== soclin-launch-installer ===="
    date -Is
    echo "user=$(id -un)"
    echo "display=${DISPLAY:-}"
    echo "desktop_session=${DESKTOP_SESSION:-}"
    echo "xdg_session_desktop=${XDG_SESSION_DESKTOP:-}"
    echo "xdg_current_desktop=${XDG_CURRENT_DESKTOP:-}"
} >> /var/log/soclin-live-debug.log 2>&1
#endregion debug-point live-installer-start
sleep 2
if pgrep -x calamares >/dev/null; then
#region debug-point live-installer-already-running
    echo "$(date -Is) calamares-already-running" >> /var/log/soclin-live-debug.log 2>&1
#endregion debug-point live-installer-already-running
    exit 0
fi
#region debug-point live-installer-exec
echo "$(date -Is) calamares-exec" >> /var/log/soclin-live-debug.log 2>&1
calamares --fullscreen >> /var/log/soclin-live-debug.log 2>&1
status=$?
echo "$(date -Is) calamares-exit=$status" >> /var/log/soclin-live-debug.log 2>&1
exit "$status"
#endregion debug-point live-installer-exec
EOF
chmod +x /usr/local/bin/soclin-launch-installer

cat <<'EOF' > /usr/local/bin/soclin-live-session
#!/bin/bash
set -e

#region debug-point live-session-start
{
    echo "==== soclin-live-session ===="
    date -Is
    echo "user=$(id -un)"
    echo "pwd=$(pwd)"
    echo "desktop_session=${DESKTOP_SESSION:-}"
    echo "xdg_session_desktop=${XDG_SESSION_DESKTOP:-}"
    echo "xdg_current_desktop=${XDG_CURRENT_DESKTOP:-}"
} >> /var/log/soclin-live-debug.log 2>&1
#endregion debug-point live-session-start

# Openbox działa tylko jako lekki WM dla Calamares. Sam instalator trzymamy
# na pierwszym planie, żeby po starcie ISO nie było widać zwykłego pulpitu.
export DESKTOP_SESSION=soclin-live
export XDG_SESSION_DESKTOP=soclin-live
export XDG_CURRENT_DESKTOP=soclin-live

openbox-session >/var/log/soclin-openbox.log 2>&1 &
openbox_pid=$!
echo "$(date -Is) openbox-pid=$openbox_pid" >> /var/log/soclin-live-debug.log 2>&1
sleep 1

set +e
/usr/local/bin/soclin-launch-installer >/var/log/soclin-launch-installer.log 2>&1
status=$?
set -e

kill "$openbox_pid" >/dev/null 2>&1 || true
wait "$openbox_pid" 2>/dev/null || true
echo "$(date -Is) live-session-exit=$status" >> /var/log/soclin-live-debug.log 2>&1
exit "$status"
EOF
chmod +x /usr/local/bin/soclin-live-session

mkdir -p /usr/share/xsessions
cat <<'EOF' > /usr/share/xsessions/soclin-live.desktop
[Desktop Entry]
Name=soclin Live
Comment=soclin live installer session
Exec=/usr/local/bin/soclin-live-session
TryExec=/usr/local/bin/soclin-live-session
Type=Application
DesktopNames=soclin-live
EOF

# Minimalny Openbox dla ISO live. Nie pokazujemy standardowego menu z akcjami
# zaleznymi od x-terminal-emulator, bo ta sesja sluzy tylko do odpalenia Calamares.
mkdir -p /etc/xdg/openbox
cat <<'EOF' > /etc/xdg/openbox/menu.xml
<?xml version="1.0" encoding="UTF-8"?>
<openbox_menu xmlns="http://openbox.org/3.4/menu">
  <menu id="root-menu" label="Openbox 3">
    <item label="Installer is starting">
      <action name="Execute">
        <command>/usr/local/bin/soclin-launch-installer</command>
      </action>
    </item>
  </menu>
</openbox_menu>
EOF
cat <<'EOF' > /etc/xdg/openbox/rc.xml
<?xml version="1.0" encoding="UTF-8"?>
<openbox_config xmlns="http://openbox.org/3.4/rc">
  <applications/>
  <desktops>
    <number>1</number>
    <firstdesk>1</firstdesk>
  </desktops>
  <keyboard/>
  <menu>
    <file>/etc/xdg/openbox/menu.xml</file>
    <hideDelay>0</hideDelay>
    <middle>false</middle>
    <submenuShowDelay>0</submenuShowDelay>
    <submenuHideDelay>0</submenuHideDelay>
    <showIcons>false</showIcons>
    <manageDesktops>false</manageDesktops>
  </menu>
  <mouse>
    <dragThreshold>1</dragThreshold>
    <doubleClickTime>500</doubleClickTime>
    <screenEdgeWarpTime>400</screenEdgeWarpTime>
    <screenEdgeWarpMouse>false</screenEdgeWarpMouse>
  </mouse>
  <resistance>
    <strength>10</strength>
    <screen_edge_strength>20</screen_edge_strength>
  </resistance>
  <focus>
    <focusNew>yes</focusNew>
    <followMouse>no</followMouse>
    <focusLast>yes</focusLast>
    <underMouse>no</underMouse>
    <focusDelay>0</focusDelay>
    <raiseOnFocus>no</raiseOnFocus>
  </focus>
  <placement>
    <policy>Smart</policy>
    <center>yes</center>
    <monitor>Primary</monitor>
    <primaryMonitor>Active</primaryMonitor>
  </placement>
  <theme>
    <name>Clearlooks</name>
    <titleLayout>NLIMC</titleLayout>
    <keepBorder>yes</keepBorder>
    <animateIconify>no</animateIconify>
    <font place="ActiveWindow">
      <name>sans</name>
      <size>10</size>
      <weight>bold</weight>
      <slant>normal</slant>
    </font>
    <font place="MenuHeader">
      <name>sans</name>
      <size>10</size>
      <weight>bold</weight>
      <slant>normal</slant>
    </font>
    <font place="MenuItem">
      <name>sans</name>
      <size>10</size>
      <weight>normal</weight>
      <slant>normal</slant>
    </font>
    <font place="OnScreenDisplay">
      <name>sans</name>
      <size>10</size>
      <weight>normal</weight>
      <slant>normal</slant>
    </font>
  </theme>
  <margins>
    <top>0</top>
    <bottom>0</bottom>
    <left>0</left>
    <right>0</right>
  </margins>
</openbox_config>
EOF
cat <<'EOF' > /etc/xdg/openbox/autostart
#!/bin/sh
:
EOF
chmod +x /etc/xdg/openbox/autostart

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

# Start jak w Ubuntu Live: automatyczne wejście tylko do sesji live.
mkdir -p /etc/sddm.conf.d
cat <<EOF > /etc/sddm.conf
[General]
DisplayServer=x11

[Users]
RememberLastSession=false
RememberLastUser=false

[Autologin]
User=live
Session=soclin-live.desktop
Relogin=false
EOF
cat <<EOF > /etc/sddm.conf.d/00-soclin-live.conf
[General]
DisplayServer=x11

[Users]
RememberLastSession=false
RememberLastUser=false

[Autologin]
User=live
Session=soclin-live.desktop
Relogin=false
EOF
systemctl enable sddm.service || true
systemctl set-default graphical.target || true

cat <<'EOF' > /home/live/.dmrc
[Desktop]
Session=soclin-live.desktop
EOF
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
