# 🖥️ SiemaOS

Minimalny system operacyjny, który po uruchomieniu wyświetla **"siema to ja"**.

Bootuje w VirtualBox (i każdym innym emulatorze/maszynie wirtualnej obsługującym BIOS boot).

## 🚀 Jak uruchomić?

### Opcja 1: Pobierz gotowe ISO z GitHub Actions
1. Wejdź w zakładkę **Actions** na GitHub
2. Kliknij ostatni udany build
3. Pobierz artifact **siemaos-iso**
4. Rozpakuj i uruchom `siemaos.iso` w VirtualBox

### Opcja 2: Zbuduj lokalnie (Linux)
```bash
sudo apt install nasm gcc gcc-multilib grub-pc-bin xorriso mtools
make iso
```
Wynikowe ISO: `build/siemaos.iso`

## 🖼️ Co zobaczysz?

Po uruchomieniu ISO w VirtualBox na ekranie pojawi się:

```
                  siema to ja
          Minimalny System Operacyjny v1.0
```

## 📁 Struktura projektu

```
├── src/
│   ├── boot.asm      # Entry point (Multiboot2)
│   ├── kernel.c      # Kernel - wyświetla tekst przez VGA
│   └── linker.ld     # Linker script
├── iso/
│   └── boot/grub/
│       └── grub.cfg  # Konfiguracja GRUB
├── .github/
│   └── workflows/
│       └── build.yml # GitHub Actions - buduje ISO
├── Makefile           # Build system
└── README.md
```

## ⚙️ VirtualBox - ustawienia maszyny

1. **New** → Name: SiemaOS, Type: **Other**, Version: **Other/Unknown**
2. RAM: **64 MB** (wystarczy)
3. Bez dysku twardego
4. Settings → Storage → dodaj ISO jako CD-ROM
5. **Start** 🎉
