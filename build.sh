#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

export LIVE_BUILD="${LIVE_BUILD:-1}"

sudo lb clean --purge || true
./auto/config
sudo lb build
