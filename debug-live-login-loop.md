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
| A | `SDDM` nie czyta finalnej konfiguracji autologowania albo inny plik nadpisuje `Session`/`User`. | High | Low | Confirmed: runtime `cat /etc/sddm.conf` pokazal drugi pusty blok `[Autologin]` z `Session=`, a journal pokazal `Unable to find autologin session entry ""`. |
| B | Sesja `soclin-live.desktop` nie jest widoczna dla `SDDM` mimo obecnosci pliku w `/usr/share/xsessions/`. | High | Low | Rejected: plik `/usr/share/xsessions/soclin-live.desktop` istnieje, a journal pokazuje pusty wpis sesji zamiast braku `soclin-live.desktop`. |
| C | Autologin probuje wejsc do sesji, ale `soclin-live-session` konczy sie natychmiast i `SDDM` wraca do loginu. | Medium | Low | Rejected for now: brak `/var/log/soclin-live-debug.log`, wiec skrypt sesji najpewniej nie wystartowal ani razu. |
| D | Build ISO nie zawiera aktualnych zmian i testowany obraz nadal ma starsza konfiguracje startu live. | Medium | Medium | Confirmed for latest retest: runtime nadal pokazuje `/etc/sddm.conf` i `/etc/sddm.conf.d/00-soclin-live.conf`, podczas gdy po fixie obraz powinien miec tylko `/etc/sddm.conf.d/99-soclin-live.conf`. |
| E | `Calamares` lub `openbox-session` wywala sesje bardzo wczesnie, a efekt uboczny wyglada jak zwykle logowanie do `live`. | Medium | Low | Rejected for now: brak `/var/log/soclin-launch-installer.log` i `/var/log/soclin-openbox-autostart.log`, wiec do tego etapu nie dochodzi. |

## Log Evidence
- Runtime evidence from user:
- `/var/log/soclin-sddm-state.log` exists and reports:
- `build_session=live-login-loop`
- `sddm_conf_present=true`
- `sddm_conf_d_present=true`
- `session_file_present=true`
- `dmrc_session_ok=true`
- Missing files:
- `/var/log/soclin-openbox-autostart.log`
- `/var/log/soclin-live-debug.log`
- `/var/log/soclin-launch-installer.log`
- `journalctl -b -u sddm --no-pager` reports:
- `Unable to find autologin session entry ""`
- `Autologin failed!`
- `cat /etc/sddm.conf` reports duplicated `[Autologin]` section where the second block contains `User=live` and empty `Session=`
- `cat /etc/sddm.conf.d/00-soclin-live.conf` reports the expected `Session=soclin-live.desktop`
- `cat /usr/share/xsessions/soclin-live.desktop` reports the expected live session entry
- Latest retest still shows `/etc/sddm.conf` present and `/etc/sddm.conf.d/00-soclin-live.conf` present, which matches the pre-fix image layout, not the post-fix one.
- Instrumentation added in `build-iso.sh` to copy `.dbg/live-login-loop.env` into the image and write `build-info.env`.
- Instrumentation added in `chroot-setup.sh` to report:
- boot-time `SDDM` state before greeter,
- entry into `Openbox` autostart,
- entry into `soclin-live-session`,
- start/exit of `soclin-launch-installer`.

## Verification Conclusion
- Current evidence says the live image contains the expected config and the new build marker, but `soclin-live-session` does not start at all.
- Confirmed root cause: the live image ends up with a duplicated `[Autologin]` block in `/etc/sddm.conf`, and the last block leaves `Session` empty, so `SDDM` attempts autologin with `""`.
- Minimal fix applied: stop generating `/etc/sddm.conf` for the live ISO and keep only one explicit file in `/etc/sddm.conf.d/99-soclin-live.conf`.
- Latest user retest is still running an older artifact, so the fix has not been verified yet.
- Next step: rebuild ISO from the commit that contains the `99-soclin-live.conf` change, then verify that `journalctl -b -u sddm` no longer shows `Unable to find autologin session entry ""`.
