# WinUX ISO Builder

Gotowy starter do zbudowania lekkiego, windows-like ISO na bazie Ubuntu 24.04 LTS.

## Co dostaniesz

- **Hyprland** jako compositor z zaokrąglonymi oknami, blur i animacjami
- **Quickshell** taskbar na dole (centered ikony, zegar, system tray, Start menu z siatką apek i power menu)
- **Fluent** motyw GTK + ikony + kursory (Windows 11 look)
- **Wine** zainstalowany domyślnie — dwuklik na `.exe` otwiera przez Wine
- **Firefox**, **Thunderbird**, **VLC**, **Thunar**, **Notatnik**, **Kalkulator** preinstalowane
- **SDDM** z autologinem — zero terminala w codziennym użyciu
- **Polskie** locale, klawiatura, katalogi (Pulpit, Dokumenty, Pobrane...)

## Wymagania na Windows

1. Windows 10 lub 11 z WSL2
2. Dystrybucja `Ubuntu-24.04` w WSL
3. Co najmniej 30 GB wolnego miejsca
4. Stabilne łącze internetowe

## Szybki start — GitHub Actions (ZALECANE)

Najwygodniejsza opcja bez lokalnej zabawy z WSL:

1. Wrzuć projekt `winux-iso` do repo na GitHub
2. Wejdź w zakładkę **Actions**
3. Wybierz **Build WinUX ISO**
4. Kliknij **Run workflow**
5. Po zakończeniu pobierz artefakt `winux-iso`

To da Ci gotowy plik `.iso`, który wrzucisz prosto do VirtualBoxa.

## Build lokalny przez WSL

### Instalacja WSL (jednorazowo)

```powershell
Set-ExecutionPolicy -Scope Process Bypass
cd d:\Soclin\winux-iso
.\install-wsl.ps1
```

Po ewentualnym restarcie uruchom raz `Ubuntu 24.04` z menu Start, załóż konto Linux.

### Budowanie ISO

```powershell
Set-ExecutionPolicy -Scope Process Bypass
cd d:\Soclin\winux-iso
.\build.ps1
```

Skrypt:
- sprawdzi WSL i dystrybucję Ubuntu
- skopiuje projekt do Linuxa
- doinstaluje zależności builda
- uruchomi `lb build` (30-90 minut)
- skopiuje gotowe ISO do `d:\Soclin\winux-iso\out`

## Wynik

```
D:\Soclin\winux-iso\out\*.iso
```

## VirtualBox — ustawienia maszyny

| Ustawienie | Wartość |
|---|---|
| Type | Linux / Ubuntu (64-bit) |
| EFI | **ON** |
| Graphics Controller | VMSVGA |
| Video Memory | 128 MB |
| 3D Acceleration | ON |
| RAM | 4096 MB |
| Dysk | nie potrzebny (live) |

1. Stwórz maszynę z powyższymi ustawieniami
2. Podepnij ISO do napędu optycznego
3. Uruchom maszynę — SDDM zaloguje automatycznie
4. Powinieneś zobaczyć pulpit z taskbarem na dole

## Struktura projektu

```
winux-iso/
├── auto/config                    # lb config flags
├── build.sh                       # Linux build entry point
├── build.ps1                      # Windows→WSL build bridge
├── install-wsl.ps1                # WSL setup helper
├── config/
│   ├── package-lists/
│   │   └── winux.list.chroot      # pakiety do zainstalowania
│   ├── hooks/normal/
│   │   ├── 010-base-setup.chroot  # locale, user, services
│   │   ├── 020-wine-i386.chroot   # Wine 32-bit + MIME + binfmt
│   │   ├── 030-build-ui.chroot    # Quickshell, themes, fonts
│   │   └── 040-user-finishing.chroot
│   ├── includes.chroot/
│   │   ├── etc/skel/.config/      # Hyprland, GTK, Qt, mako...
│   │   ├── usr/local/share/winux-shell/main.qml
│   │   ├── usr/share/applications/wine-exe.desktop
│   │   └── usr/share/wayland-sessions/winux.desktop
│   └── includes.binary/
│       └── boot/grub/grub.cfg
└── .github/workflows/build-iso.yml
```

## Obsługa plików .exe

Każdy plik `.exe` otwiera się automatycznie przez Wine po dwukliku w Thunarze. Działają:
- kernel `binfmt_misc` (przechwytuje MZ header)
- MIME association (`wine-exe.desktop`)
- wrapper script (`~/.local/bin/wine-open-exe.sh`)

Do gier użyj **Lutris** (w Start menu).

## Uwagi

- **Segoe UI** nie jest dołączone (licencja). Domyślnie używany jest **Inter**.
- Hook `030-build-ui.chroot` próbuje zbudować Quickshell i caelestia ze źródeł. Jeśli upstream się zmieni, fallback shell `main.qml` i tak zostaje w ISO.
- VirtualBox ma ograniczone wsparcie Wayland — kursor software'owy jest włączony domyślnie.
- Sam proces budowy potrzebuje Linuxa (WSL lub GitHub Actions runner).
