#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(
  cd -P "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1
  pwd
)"

LAUNCHER_DIR="$(
  cd -P "$SCRIPT_DIR/.." >/dev/null 2>&1
  pwd
)"

SHARED_LAUNCHER="$LAUNCHER_DIR/linux_start_opencode.sh"

if [ ! -f "$SHARED_LAUNCHER" ]; then
  echo "ERROR: Shared launcher was not found:"
  echo "  $SHARED_LAUNCHER"
  echo
  read -r -p "Press Enter to close..." _ || true
  exit 1
fi

exec bash "$SHARED_LAUNCHER" prd