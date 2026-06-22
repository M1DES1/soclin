$ErrorActionPreference = "Stop"

Write-Host "[1/3] Wlaczam WSL i Virtual Machine Platform..."
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart | Out-Host
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart | Out-Host

Write-Host "[2/3] Ustawiam WSL2 jako domyslne..."
wsl.exe --set-default-version 2 | Out-Host

Write-Host "[3/3] Instaluje Ubuntu 24.04 do WSL..."
wsl.exe --install -d Ubuntu-24.04 --no-launch | Out-Host

Write-Host ""
Write-Host "Jesli Windows poprosi o restart, zrestartuj komputer."
Write-Host "Po restarcie uruchom raz Ubuntu 24.04, utworz konto Linux i dopiero potem odpal:"
Write-Host "  .\\build.ps1"
