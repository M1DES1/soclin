# soclin-iso (Linux Base)

W pełni funkcjonalny, startowy obraz Linuksa typu live ISO, z automatycznym uruchamianiem graficznego instalatora `Calamares` stylizowanego pod `Windows 11`.

Po starcie VM nie pojawia się ekran logowania ani zwykły pulpit. ISO przechodzi od razu do instalatora systemu.

## Główne założenia
- **Instalator**: pełnoekranowy `Calamares`.
- **Start ISO**: automatyczne wejście do sesji live i natychmiastowy start instalatora.
- **Wygląd**: jasny motyw, niebieskie akcenty, zaokrąglone elementy i układ inspirowany `Windows 11`.
- **Budowanie**: własny obraz live na bazie Ubuntu Noble budowany przez `debootstrap`.

## Jak pobrać / zbudować?

### Pobieranie z GitHub Actions
Projekt używa **GitHub Actions**, aby wygenerować gotowy obraz `.iso`.
1. Wejdź do zakładki **Actions** tego repozytorium.
2. Otwórz u góry najnowszy *Workflow run*.
3. Pobierz `winux-iso` z sekcji Artifacts na samym dole.
4. Wyodrębnij `.zip` - otworzy się gotowe `.iso`.

### Budowanie Lokalne
Instrukcja zoptymalizowana pod natywnego Linuksa lub WSL2 z odpowiednimi narzędziami.

1. Zainstaluj `squashfs-tools debootstrap xorriso grub-pc-bin grub-efi-amd64-bin`.
2. Otwórz projekt w konsoli.
3. Wpisz komendę: `sudo ./build-iso.sh`
4. Czekaj, aż build przygotuje środowisko live i spakuje obraz.
5. Wynikiem będzie plik `soclin-YYYYMMDD.iso` dostępny w bieżącym katalogu.

## Uruchomienie ISO

Wygenerowane ISO jest bootowalne. Możesz uruchomić je przez:
- Maszynę wirtualną – polecane: Oracle VirtualBox, wirtualizacja standardu Linuksa Ubuntu x64 (lub Inny Linux/UEFI).
- Zrzucenie na pendrive za pomocą programu **Rufus** i zbootowanie go z PC.

Po starcie obrazu uruchamia się bezpośrednio pełnoekranowy `Calamares`, bez ekranu logowania i bez zwykłego pulpitu.
