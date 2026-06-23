# GitHub Build Files

Ten katalog trzyma kopie plikow potrzebnych do budowania ISO w GitHub Actions.

## Zawartosc

- `iso-build/auto/`
- `iso-build/config/`
- `iso-build/build.sh`

## Jak to dziala

Workflow z `.github/workflows/build-iso.yml` kopiuje ten katalog do katalogu roboczego runnera i uruchamia `build.sh`.

## Uwagi

- Kopia w `github/iso-build` jest przeznaczona pod CI.
- W tej kopii usuwany jest `config/archives/debian.list.chroot`, zeby build nie mieszal Ubuntu `noble` z Debianem `bookworm` podczas pracy na runnerze GitHub.
