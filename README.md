# WinUX ISO Builder

Gotowy starter do zbudowania lekkiego, windows-like ISO na bazie Ubuntu 24.04 LTS.

## Co to robi

- buduje ISO przez `live-build`
- ustawia `Hyprland` jako sesje graficzna
- dodaje dolny taskbar i launcher przez `Quickshell`
- instaluje `Wine`, `Winetricks`, `Lutris` i skojarzenia `.exe`
- ustawia `SDDM`, motyw Fluent i aplikacje GUI
- uruchamia build z Windows przez `PowerShell -> WSL`

## Wymagania na Windows

1. Windows 11 lub 10 z WSL2
2. Dystrybucja `Ubuntu-24.04` w WSL
3. Co najmniej 30 GB wolnego miejsca
4. Stabilne lacze internetowe

## Szybki start

Najwygodniejsza opcja bez lokalnej zabawy z `WSL` i BIOS-em to build w chmurze przez `GitHub Actions`.

## Build Bez Wirtualizacji Lokalnie

Nie da sie sensownie zbudowac pelnego Ubuntu-based live ISO na czystym Windowsie bez jakiegos Linuxowego srodowiska builda, ale nie musi to byc Twoj komputer.

Masz juz gotowy workflow:

- [build-iso.yml](file:///d:/Soclin/winux-iso/.github/workflows/build-iso.yml)

Jak go uzyc:

1. wrzuc projekt `winux-iso` do repo na GitHub
2. wejdz w zakladke `Actions`
3. wybierz `Build WinUX ISO`
4. kliknij `Run workflow`
5. po zakonczeniu pobierz artefakt `winux-iso`

To da Ci gotowy plik `.iso`, ktory wrzucisz prosto do VirtualBoxa.

## Build Lokalny Przez WSL

Jesli nie masz jeszcze Ubuntu w WSL, uruchom najpierw:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
cd d:\Soclin\winux-iso
.\install-wsl.ps1
```

Po ewentualnym restarcie uruchom raz `Ubuntu 24.04` z menu Start, zaloz konto Linux i dopiero wtedy wykonaj build.

Wlasciwy build:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
cd d:\Soclin\winux-iso
.\build.ps1
```

Skrypt:

- sprawdzi WSL
- skopiuje projekt do Linuxa
- doinstaluje zaleznosci build hosta
- uruchomi `lb build`
- skopiuje gotowe ISO do `d:\Soclin\winux-iso\out`

## Wynik

Gotowy obraz pojawi sie w:

```text
D:\Soclin\winux-iso\out
```

## VirtualBox

Rekomendowane ustawienia maszyny:

- Type: Linux / Ubuntu (64-bit)
- EFI: ON
- Graphics Controller: VMSVGA
- Video Memory: 128 MB
- 3D Acceleration: ON
- RAM: 4096 MB do testow

## Uwagi

- `Segoe UI` nie jest dolaczone, bo to problem licencyjny. Domyslnie uzywany jest `Inter`.
- Hook budujacy `Quickshell` i `caelestia` probuje zbudowac prawdziwy shell. Jesli upstream sie zmieni albo build nie przejdzie, fallback shell `main.qml` i tak zostaje w ISO.
- Domyslnie wykonywany jest build pelny. Dla szybszych iteracji mozesz komentowac kosztowne hooki w `config/hooks/normal`.
- `VirtualBox` jest tylko celem uruchomienia gotowego ISO. Sam proces budowy nadal potrzebuje Linuksa lokalnie albo runnera Linuksowego w chmurze.
