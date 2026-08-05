#!/usr/bin/env bash
# OpenCode launcher for the dual-boot AI server.
# Usage: ./ai_open_opencode.sh dev|prd

if [ -z "${BASH_VERSION:-}" ]; then
  exec bash "$0" "$@"
fi

set -Eeuo pipefail

SCRIPT_FILE="${BASH_SOURCE[0]}"
SCRIPT_DIR="$(cd -P "$(dirname "$SCRIPT_FILE")" >/dev/null 2>&1 && pwd)"
LIB_DIR="$SCRIPT_DIR/scripts/lib"
ENVIRONMENT="${1:-}"

if [ -z "$ENVIRONMENT" ]; then
  echo "Select environment:"
  echo "  1) Development"
  echo "  2) Pre-Production"
  echo
  read -r -p "Enter 1 or 2: " choice

  case "$choice" in
    1) ENVIRONMENT="dev" ;;
    2) ENVIRONMENT="prd" ;;
    *)
      echo "Invalid selection."
      read -r -p "Press Enter to close..." _
      exit 2
      ;;
  esac
fi

for required in settings.sh common.sh ssh_key.sh tunnel.sh opencode_config.sh opencode_runtime.sh; do
  if [ ! -f "$LIB_DIR/$required" ]; then
    echo "ERROR: Missing required file: $LIB_DIR/$required"
    exit 1
  fi
done

. "$LIB_DIR/settings.sh"
. "$LIB_DIR/common.sh"
. "$LIB_DIR/ssh_key.sh"
. "$LIB_DIR/tunnel.sh"
. "$LIB_DIR/opencode_config.sh"
. "$LIB_DIR/opencode_runtime.sh"

main() {
  configure_environment "$ENVIRONMENT"
  refresh_path
  initialize_runtime_paths
  log_header
  show_startup_banner

  find_or_install_key || pause_exit 1
  echo "SSH key ready: $KEY"

  ensure_ssh_access
  start_tunnels
  trap stop_tunnels EXIT INT TERM

  check_backends

  CONFIG_PATH="$(write_opencode_config)"
  echo "OpenCode config written: $CONFIG_PATH"
  echo

  launch_opencode
}

main "$@"
