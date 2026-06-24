# Debug Session: live-login-loop
- **Status**: [OPEN]
- **Issue**: ISO nadal pokazuje logowanie do uzytkownika `live` zamiast od razu uruchomic instalator `Calamares`; po zalogowaniu widoczny jest pusty/czarny pulpit.
- **Debug Server**: http://192.168.50.168:7777/event
- **Log File**: .dbg/trae-debug-log-live-login-loop.ndjson

## Reproduction Steps
1. Zbudowac nowe ISO z aktualnego repo.
2. Uruchomic ISO w VM.
3. Sprawdzic, czy pojawia sie ekran logowania `live` zamiast automatycznego wejscia do sesji live.
4. Jesli pojawi sie login, zalogowac sie jako `live` i sprawdzic, czy `Calamares` startuje.

## Hypotheses & Verification
| ID | Hypothesis | Likelihood | Effort | Evidence |
|----|------------|------------|--------|----------|
| A | `SDDM` nie czyta finalnej konfiguracji autologowania albo inny plik nadpisuje `Session`/`User`. | High | Low | Pending |
| B | Sesja `soclin-live.desktop` nie jest widoczna dla `SDDM` mimo obecnosci pliku w `/usr/share/xsessions/`. | High | Low | Pending |
| C | Autologin probuje wejsc do sesji, ale `soclin-live-session` konczy sie natychmiast i `SDDM` wraca do loginu. | Medium | Low | Pending |
| D | Build ISO nie zawiera aktualnych zmian i testowany obraz nadal ma starsza konfiguracje startu live. | Medium | Medium | Pending |
| E | `Calamares` lub `openbox-session` wywala sesje bardzo wczesnie, a efekt uboczny wyglada jak zwykle logowanie do `live`. | Medium | Low | Pending |

## Log Evidence
- Pending
- Instrumentation added in `build-iso.sh` to copy `.dbg/live-login-loop.env` into the image and write `build-info.env`.
- Instrumentation added in `chroot-setup.sh` to report:
- boot-time `SDDM` state before greeter,
- entry into `Openbox` autostart,
- entry into `soclin-live-session`,
- start/exit of `soclin-launch-installer`.

## Verification Conclusion
- Pending
