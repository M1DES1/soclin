$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$OutDir = Join-Path $ProjectRoot "out"
$Distro = "Ubuntu-24.04"
$LinuxUser = (wsl.exe -d $Distro -- bash -lc "id -un").Trim()
$LinuxProjectDir = "/home/$LinuxUser/winux-iso"

function Require-Command($Name) {
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Brak wymaganego polecenia: $Name"
    }
}

Require-Command "wsl.exe"
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

Write-Host "[1/5] Sprawdzam WSL..."
wsl.exe -d $Distro -- bash -lc "uname -a" | Out-Host

Write-Host "[2/5] Kopiuje projekt do WSL..."
$linuxRoot = wsl.exe -d $Distro -- bash -lc "wslpath -a '$ProjectRoot'"
$escapedLinuxRoot = $linuxRoot.Trim()
wsl.exe -d $Distro -- bash -lc "rm -rf '$LinuxProjectDir' && mkdir -p '$LinuxProjectDir' && cp -a '$escapedLinuxRoot/.' '$LinuxProjectDir/'"

Write-Host "[3/5] Doinstalowuje zaleznosci hosta builda..."
wsl.exe -d $Distro -- bash -lc "sudo apt update && sudo apt install -y live-build debootstrap squashfs-tools xorriso grub-pc-bin grub-efi-amd64-bin mtools dosfstools rsync wget curl git ca-certificates gnupg2 jq software-properties-common apt-transport-https"

Write-Host "[4/5] Uruchamiam build ISO..."
wsl.exe -d $Distro -- bash -lc "cd '$LinuxProjectDir' && chmod +x build.sh auto/config config/hooks/normal/*.chroot config/includes.chroot/etc/skel/.local/bin/*.sh && ./build.sh"

Write-Host "[5/5] Kopiuje wynik do Windows..."
wsl.exe -d $Distro -- bash -lc "mkdir -p '$LinuxProjectDir/out' && find '$LinuxProjectDir' -maxdepth 1 -type f -name '*.iso' -exec cp {} '$LinuxProjectDir/out/' \;"
$linuxOut = wsl.exe -d $Distro -- bash -lc "wslpath -w '$LinuxProjectDir/out'"
$windowsOut = $linuxOut.Trim()
Copy-Item -Path (Join-Path $windowsOut "*.iso") -Destination $OutDir -Force

Write-Host "Gotowe. ISO znajdziesz w: $OutDir"
