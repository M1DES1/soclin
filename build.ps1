$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$OutDir = Join-Path $ProjectRoot "out"
$Distro = "Ubuntu-24.04"

function Require-Command($Name) {
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Brak wymaganego polecenia: $Name. Zainstaluj WSL2 i Ubuntu-24.04."
    }
}

function Test-WSLDistro($Name) {
    $list = wsl.exe --list --quiet 2>&1
    return ($list -match $Name)
}

Require-Command "wsl.exe"

if (-not (Test-WSLDistro $Distro)) {
    Write-Host "Nie znaleziono dystrybucji $Distro w WSL." -ForegroundColor Red
    Write-Host "Uruchom najpierw: .\install-wsl.ps1" -ForegroundColor Yellow
    exit 1
}

$LinuxUser = (wsl.exe -d $Distro -- bash -lc "id -un").Trim()
$LinuxProjectDir = "/home/$LinuxUser/winux-iso"

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

Write-Host ""
Write-Host "=== WinUX ISO Builder ===" -ForegroundColor Cyan
Write-Host ""

Write-Host "[1/5] Sprawdzam WSL..." -ForegroundColor Green
wsl.exe -d $Distro -- bash -lc "uname -a" | Out-Host

Write-Host "[2/5] Kopiuje projekt do WSL..." -ForegroundColor Green
$linuxRoot = wsl.exe -d $Distro -- bash -lc "wslpath -a '$ProjectRoot'"
$escapedLinuxRoot = $linuxRoot.Trim()
wsl.exe -d $Distro -- bash -lc "rm -rf '$LinuxProjectDir' && mkdir -p '$LinuxProjectDir' && cp -a '$escapedLinuxRoot/.' '$LinuxProjectDir/'"

Write-Host "[3/5] Doinstalowuje zaleznosci hosta builda..." -ForegroundColor Green
wsl.exe -d $Distro -- bash -lc "sudo apt update && sudo apt install -y live-build debootstrap squashfs-tools xorriso grub-pc-bin grub-efi-amd64-bin mtools dosfstools rsync wget curl git ca-certificates gnupg2 jq software-properties-common apt-transport-https"

Write-Host "[4/5] Uruchamiam build ISO (to moze trwac 30-90 minut)..." -ForegroundColor Green
wsl.exe -d $Distro -- bash -lc "cd '$LinuxProjectDir' && chmod +x build.sh auto/config && find config/hooks/normal -type f -name '*.chroot' -exec chmod +x {} \; && find config/includes.chroot -type f -name '*.sh' -exec chmod +x {} \; 2>/dev/null; ./build.sh"

Write-Host "[5/5] Kopiuje wynik do Windows..." -ForegroundColor Green
wsl.exe -d $Distro -- bash -lc "mkdir -p '$LinuxProjectDir/out' && find '$LinuxProjectDir' -maxdepth 1 -type f -name '*.iso' -exec cp {} '$LinuxProjectDir/out/' \;"
$linuxOut = wsl.exe -d $Distro -- bash -lc "wslpath -w '$LinuxProjectDir/out'"
$windowsOut = $linuxOut.Trim()

$isoFiles = Get-ChildItem -Path $windowsOut -Filter "*.iso" -ErrorAction SilentlyContinue
if ($isoFiles) {
    Copy-Item -Path (Join-Path $windowsOut "*.iso") -Destination $OutDir -Force
    Write-Host ""
    Write-Host "=== Gotowe! ===" -ForegroundColor Green
    foreach ($f in (Get-ChildItem -Path $OutDir -Filter "*.iso")) {
        $sizeMB = [math]::Round($f.Length / 1MB)
        Write-Host "  ISO: $($f.Name) ($sizeMB MB)" -ForegroundColor Cyan
    }
    Write-Host "  Folder: $OutDir" -ForegroundColor Cyan
} else {
    Write-Host ""
    Write-Host "BLAD: Nie znaleziono pliku ISO. Sprawdz logi builda powyzej." -ForegroundColor Red
    exit 1
}
