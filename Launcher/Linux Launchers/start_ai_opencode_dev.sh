<<<<<<< HEAD
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

exec bash "$SHARED_LAUNCHER" dev
``
=======
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

<<<<<<< HEAD
exec "$ROOT_DIR/ai_open_opencode.sh" dev "$@"
>>>>>>> dffd222 (Add files via upload)
=======
exec bash "$SHARED_LAUNCHER" dev
``
>>>>>>> 3ebe8a0 (Add repository attributes and ignore rules)
