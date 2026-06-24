# Debug Session: live-login-black-screen

Status: OPEN

## Symptom
- Po starcie ISO pojawia się logowanie użytkownika `live`.
- Po wejściu do GUI widać czarny pulpit `Openbox`.
- Pojawia się błąd `Failed to execute child process "x-terminal-emulator"`.

## Expected
- Boot ISO nie pokazuje ekranu logowania.
- Po starcie nie widać zwykłego pulpitu `Openbox`.
- Od razu uruchamia się pełnoekranowy `Calamares`.

## Hypotheses
1. `SDDM` nie wchodzi w autologin do sesji `soclin-live`, tylko pokazuje greeter przez złą nazwę sesji lub złą finalną konfigurację.
2. Sesja `soclin-live` startuje, ale `Calamares` nie uruchamia się lub kończy zbyt wcześnie, więc zostaje sam czarny `Openbox`.
3. `Openbox` ładuje domyślną konfigurację systemową z menu odwołującym się do `x-terminal-emulator`, bo nie ma własnej minimalnej konfiguracji live.
4. Brakuje spójnego autostartu lub blokady interakcji z pulpitem, więc użytkownik trafia do zwykłej sesji zamiast do dedykowanego instalatora.
5. Budowane ISO nie zawiera dokładnie tej konfiguracji sesji live, którą zakładamy w repo.

## Evidence To Collect
- Końcowa konfiguracja `SDDM` i nazwa sesji live.
- Źródła konfiguracji `Openbox`, w tym `rc.xml`, `menu.xml` i autostart.
- Miejsca, gdzie może być wywoływany `x-terminal-emulator`.
- Logi helpera startowego i sesji live.

## Next Step
- Dodać lub uzupełnić instrumentację dla wyboru sesji live i konfiguracji `Openbox`, potem zminimalizować pulpit dopiero po potwierdzeniu przyczyny.
