# Winux-ISO (Linux Base)

W pełni funkcjonalny, startowy obraz Linuksa (Live ISO na bazie Ubuntu) upodobniony do systemu Windows 11. 
Budowany od podstaw przy pomocy skryptu `debootstrap` w środowisku GitHub Actions.

## Główne różnice w stosunku do zwykłego Ubuntu:
- **Instalator**: graficzny instalator `Calamares` z klasycznym przebiegiem konfiguracji, tworzeniem konta użytkownika i własnym brandingiem.
- **Środowisko graficzne**: [Hyprland](https://hyprland.org) pobierany i budowany **ze źródeł**, używające zaokrąglonych krawędzi i bluru (estetyka Windows 11).
- **Aplikacje EXE**: Wbudowane i pre-konfigurowane `Wine`. Każdy plik Windowsowego `.exe` uruchamia się natywnie podwójnym kliknięciem (kojarzony plik z Mime).
- **Estetyka**: Zintegrowany WhiteSur-Light GTK.
- **Skróty klawiszowe**: Np. `Win + E` uruchamia menedżer plików Thunar.

## Jak pobrać / zbudować?

### Pobieranie z GitHub Actions (Zalecane)
Nasz projekt używa **GitHub Actions**, aby samodzielnie wygenerować obraz `.iso`.
1. Wejdź do zakładki **Actions** tego repozytorium.
2. Otwórz u góry najnowszy *Workflow run*.
3. Pobierz `winux-iso` z sekcji Artifacts na samym dole.
4. Wyodrębnij `.zip` - otworzy się gotowe `.iso`.

### Budowanie Lokalne
Instrukcja zoptymalizowana pod natywnego Linuksa (lub WSL2 z odpowiednimi narzędziami). Budowanie wymaga uprawnień roota do `chroot`.

1. Zainstaluj `squashfs-tools debootstrap xorriso grub-pc-bin grub-efi-amd64-bin`.
2. Otwórz projekt w konsoli.
3. Wpisz komendę: `sudo ./build-iso.sh`
4. Czekaj (proces ściągania źródeł i paczek ubuntu potrwa dłuższą chwilę).
5. Wynikiem będzie plik `siemaos-data.iso` dostępny w bieżącym pliku.

## Uruchomienie ISO

Wygenerowane ISO jest bootowalne. Możesz uruchomić je przez:
- Maszynę wirtualną – polecane: Oracle VirtualBox, wirtualizacja standardu Linuksa Ubuntu x64 (lub Inny Linux/UEFI).
- Zrzucenie na pendrive za pomocą programu **Rufus** i zbootowanie go z PC.

Po starcie obrazu uruchamia się sesja live z pełnym instalatorem `Calamares`, w którym użytkownik wybiera ustawienia systemu i tworzy własne konto docelowe.
