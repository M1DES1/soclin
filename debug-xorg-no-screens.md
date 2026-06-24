# Debug Session: xorg-no-screens

Status: OPEN

## Symptom
- X.Org kończy start w sesji live błędem `no screens found`.
- W logu widać `xf86EnableIO: failed to enable I/O ports 0000-03ff (Operation not permitted)`.

## Expected
- Sesja live uruchamia `startx`, startuje `openbox-session`, a potem `calamares`.

## Initial Hypotheses
1. X.Org wybiera sterownik lub ścieżkę dostępu do framebuffera, która w tym środowisku VM wymaga uprawnień niedostępnych dla użytkownika `live`.
2. Zainstalowane pakiety `xserver-xorg-video-fbdev` lub `xserver-xorg-video-vesa` wymuszają zły fallback i blokują poprawne wykrycie ekranu.
3. Brakuje odpowiedniego dostępu do urządzeń graficznych dla użytkownika `live` lub sesji uruchamianej przez `startx` z `tty1`.
4. Środowisko VM używa kontrolera graficznego, dla którego potrzeba innego pakietu X.Org lub innej konfiguracji niż obecna minimalna sesja.
5. Problem nie dotyczy samego X.Org, tylko sposobu autologowania i uruchamiania `startx`, który daje inną ścieżkę startu niż klasyczny display manager.

## Evidence To Collect
- Jakie pakiety i fallbacki X.Org są instalowane.
- Jak wygląda logika startu sesji `live`.
- Czy istnieje jawna konfiguracja X.Org lub sterowników.
- Które elementy są specyficzne dla VirtualBox/live.

## Next Step
- Zebrać dowody z plików builda i startu sesji, a dopiero potem dodać minimalną instrumentację lub poprawkę.
