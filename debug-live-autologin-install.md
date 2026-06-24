# Debug Session: live-autologin-install

Status: OPEN

## Symptom
- Nadal pojawia się okno logowania `live`.
- Nadal pojawia się czarny pulpit `Openbox` zamiast natychmiastowego startu `Calamares`.
- Instalator potrafi zakończyć się błędem przy etapie systemowym, m.in. przy `initrd`.

## Expected
- Boot ISO automatycznie loguje użytkownika `live`.
- Po wejściu do GUI od razu startuje `Calamares`.
- Instalacja przechodzi bez błędów związanych z brakującymi plikami lub komendami.

## Hypotheses
1. `sddm` nie czyta plików z `/etc/sddm.conf.d/` tak, jak zakładamy, albo wymaga innego klucza dla autologowania.
2. Nazwa sesji w `Autologin` nie odpowiada temu, co `sddm` realnie widzi w `/usr/share/xsessions/`.
3. Sesja `soclin-live` startuje, ale `Calamares` wywala się bardzo wcześnie i zostaje sam `Openbox`.
4. Błąd instalacji z `touch //boot/initrd.img-$(uname -r)` wynika z niepoprawnej kolejności modułów Calamares lub skryptu oczekującego `/boot` przed jego utworzeniem.
5. Budowany obraz ISO nie zawiera aktualnych zmian i testowany jest starszy artefakt.

## Evidence To Collect
- Jak wygląda końcowa konfiguracja `sddm` i sesji live wewnątrz chroot.
- Czy pliki sesji w `/usr/share/xsessions/` są poprawne.
- Czy `Calamares` ma log lub helper startowy, z którego da się odczytać punkt awarii.
- Który moduł lub skrypt Calamares wykonuje `touch //boot/initrd.img-*`.

## Next Step
- Dodać minimalną instrumentację logującą wybór sesji live i start instalatora oraz znaleźć źródło komendy `touch //boot/initrd.img-*`.

## Evidence Collected
- `mksquashfs` w [build-iso.sh](file:///d:/Soclin/winux-iso/build-iso.sh#L53-L55) wycinał całe `boot`, więc unpackowany system docelowy nie musiał mieć nawet katalogu `/boot`.
- Zgłoszony błąd runtime mówi wprost o `touch /boot/initrd.img-*`, co jest spójne z brakiem katalogu `/boot`.
- Konfiguracja `sddm` była rozproszona tylko po `/etc/sddm.conf.d/`, a `Session` była już kilkukrotnie zmieniana między nazwą z i bez `.desktop`, więc autologin wymagał bardziej jednoznacznej konfiguracji.
- Dodano logowanie runtime do `/var/log/soclin-live-debug.log` oraz `/var/log/soclin-launch-installer.log`, aby następny test pokazał, czy sesja live i `Calamares` rzeczywiście startują.

## Fix Applied
- Zmieniono konfigurację `sddm`, aby zapisywać pełny `/etc/sddm.conf` oraz spójne pliki w `/etc/sddm.conf.d/` z `Session=soclin-live.desktop`.
- Zmieniono budowę squashfs tak, aby nie wycinać całego katalogu `boot`, tylko same live pliki `vmlinuz*` i `initrd.img*`.
- Rozszerzono cleanup po instalacji o usuwanie `/etc/sddm.conf`.
