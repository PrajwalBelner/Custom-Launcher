<<<<<<< HEAD

if [ -z "${BASH_VERSION:-}" ]; then
  exec bash "$0" "$@"
fi

set -Eeuo pipefail

SCRIPT_FILE="${BASH_SOURCE[0]}"
SCRIPT_DIR="$(
  cd -P "$(dirname "$SCRIPT_FILE")" >/dev/null 2>&1
  pwd
)"

LIB_DIR="$SCRIPT_DIR/scripts/lib"
ENVIRONMENT="${1:-}"

pause_before_exit() {
  if [ -t 0 ]; then
    echo
    read -r -p "Press Enter to close..." _ || true
  fi
}

select_environment() {
  if [ -n "$ENVIRONMENT" ]; then
    case "$ENVIRONMENT" in
      dev|prd)
        return 0
        ;;
      *)
        echo "ERROR: Invalid environment: $ENVIRONMENT" >&2
        echo "Expected: dev or prd" >&2
        pause_before_exit
        exit 2
        ;;
    esac
  fi

  echo "============================================================"
  echo "AI OpenCode Launcher"
  echo "============================================================"
  echo
  echo "Select the server environment:"
  echo
  echo "  1) Development"
  echo "     192.168.191.61"
  echo
  echo "  2) Pre-Production"
  echo "     prd@192.168.191.62"
  echo

  read -r -p "Enter 1 or 2: " choice

  case "$choice" in
    1)
      ENVIRONMENT="dev"
      ;;
    2)
      ENVIRONMENT="prd"
      ;;
    *)
      echo
      echo "ERROR: Invalid environment selection." >&2
      pause_before_exit
      exit 2
      ;;
  esac
}

select_development_profile() {
  if [ "$ENVIRONMENT" != "dev" ]; then
    return 0
  fi

  # The Development Windows launcher may already have supplied the profile.
  if [ -n "${OPENCODE_HOST_USER:-}" ]; then
    case "$OPENCODE_HOST_USER" in
      dhu|pgs|ark|tl)
        export OPENCODE_HOST_USER
        return 0
        ;;
      *)
        echo "ERROR: Unsupported Development SSH profile: $OPENCODE_HOST_USER" >&2
        echo "Supported profiles: dhu, pgs, ark, tl" >&2
        pause_before_exit
        exit 2
        ;;
    esac
  fi

  echo
  echo "Select your Development SSH profile:"
  echo
  echo "  1) dhu"
  echo "  2) pgs"
  echo "  3) ark"
  echo "  4) tl"
  echo

  read -r -p "Enter 1, 2, 3, or 4: " profile_choice

  case "$profile_choice" in
    1)
      OPENCODE_HOST_USER="dhu"
      ;;
    2)
      OPENCODE_HOST_USER="pgs"
      ;;
    3)
      OPENCODE_HOST_USER="ark"
      ;;
    4)
      OPENCODE_HOST_USER="tl"
      ;;
    *)
      echo
      echo "ERROR: Invalid Development profile selection." >&2
      pause_before_exit
      exit 2
      ;;
  esac

  export OPENCODE_HOST_USER
}

is_windows_git_bash() {
  command -v cygpath >/dev/null 2>&1 &&
    command -v powershell.exe >/dev/null 2>&1
}

select_windows_project_folder() {
  local selected_folder

  echo
  echo "Select the project folder that OpenCode should work with..."

  selected_folder="$(
    powershell.exe -NoProfile -STA -Command '
      $shell = New-Object -ComObject Shell.Application
      $folder = $shell.BrowseForFolder(
        0,
        "Select the working folder for OpenCode",
        0,
        0
      )

      if ($null -ne $folder) {
        $folder.Self.Path
      }
    ' 2>/dev/null |
      tr -d '\r'
  )"

  if [ -z "$selected_folder" ]; then
    echo
    echo "Folder selection was cancelled."
    exit 0
  fi

  OPENCODE_PROJECT_DIR="$(
    cygpath -u "$selected_folder" 2>/dev/null
  )" || {
    echo "ERROR: Could not convert the selected Windows path." >&2
    pause_before_exit
    exit 1
  }

  export OPENCODE_PROJECT_DIR
}

select_project_directory() {
  # The Windows launcher or another caller may already have supplied a folder.
  if [ -n "${OPENCODE_PROJECT_DIR:-}" ]; then
    export OPENCODE_PROJECT_DIR
    return 0
  fi

  # Direct execution through Git Bash on Windows opens a folder picker.
  if is_windows_git_bash; then
    select_windows_project_folder
    return 0
  fi

  # Linux and WSL use the terminal's current working directory.
  OPENCODE_PROJECT_DIR="$PWD"
  export OPENCODE_PROJECT_DIR
}

validate_required_files() {
  local required

  for required in \
    settings.sh \
    common.sh \
    ssh_key.sh \
    tunnel.sh \
    opencode_config.sh \
    opencode_runtime.sh
  do
    if [ ! -f "$LIB_DIR/$required" ]; then
      echo "ERROR: Missing required file: $LIB_DIR/$required" >&2
      pause_before_exit
      exit 1
    fi
  done
}

select_environment
select_development_profile
select_project_directory
validate_required_files

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

=======

if [ -z "${BASH_VERSION:-}" ]; then
  exec bash "$0" "$@"
fi

set -Eeuo pipefail

SCRIPT_FILE="${BASH_SOURCE[0]}"
SCRIPT_DIR="$(
  cd -P "$(dirname "$SCRIPT_FILE")" >/dev/null 2>&1
  pwd
)"

LIB_DIR="$SCRIPT_DIR/scripts/lib"
ENVIRONMENT="${1:-}"

pause_before_exit() {
  if [ -t 0 ]; then
    echo
    read -r -p "Press Enter to close..." _ || true
  fi
}

select_environment() {
  if [ -n "$ENVIRONMENT" ]; then
    case "$ENVIRONMENT" in
      dev|prd)
        return 0
        ;;
      *)
        echo "ERROR: Invalid environment: $ENVIRONMENT" >&2
        echo "Expected: dev or prd" >&2
        pause_before_exit
        exit 2
        ;;
    esac
  fi

  echo "============================================================"
  echo "AI OpenCode Launcher"
  echo "============================================================"
  echo
  echo "Select the server environment:"
  echo
  echo "  1) Development"
  echo "     192.168.191.61"
  echo
  echo "  2) Pre-Production"
  echo "     prd@192.168.191.62"
  echo

  read -r -p "Enter 1 or 2: " choice

  case "$choice" in
    1)
      ENVIRONMENT="dev"
      ;;
    2)
      ENVIRONMENT="prd"
      ;;
    *)
      echo
      echo "ERROR: Invalid environment selection." >&2
      pause_before_exit
      exit 2
      ;;
  esac
}

select_development_profile() {
  if [ "$ENVIRONMENT" != "dev" ]; then
    return 0
  fi

  # The Development Windows launcher may already have supplied the profile.
  if [ -n "${OPENCODE_HOST_USER:-}" ]; then
    case "$OPENCODE_HOST_USER" in
      dhu|pgs|ark|tl)
        export OPENCODE_HOST_USER
        return 0
        ;;
      *)
        echo "ERROR: Unsupported Development SSH profile: $OPENCODE_HOST_USER" >&2
        echo "Supported profiles: dhu, pgs, ark, tl" >&2
        pause_before_exit
        exit 2
        ;;
    esac
  fi

  echo
  echo "Select your Development SSH profile:"
  echo
  echo "  1) dhu"
  echo "  2) pgs"
  echo "  3) ark"
  echo "  4) tl"
  echo

  read -r -p "Enter 1, 2, 3, or 4: " profile_choice

  case "$profile_choice" in
    1)
      OPENCODE_HOST_USER="dhu"
      ;;
    2)
      OPENCODE_HOST_USER="pgs"
      ;;
    3)
      OPENCODE_HOST_USER="ark"
      ;;
    4)
      OPENCODE_HOST_USER="tl"
      ;;
    *)
      echo
      echo "ERROR: Invalid Development profile selection." >&2
      pause_before_exit
      exit 2
      ;;
  esac

  export OPENCODE_HOST_USER
}

is_windows_git_bash() {
  command -v cygpath >/dev/null 2>&1 &&
    command -v powershell.exe >/dev/null 2>&1
}

get_project_state_file() {
  local state_dir

  if is_windows_git_bash; then
    state_dir="${LOCALAPPDATA:-}"

    if [ -n "$state_dir" ]; then
      state_dir="$(cygpath -u "$state_dir" 2>/dev/null)" || state_dir=""
    fi

    if [ -z "$state_dir" ]; then
      state_dir="$HOME/.local/state"
    fi
  else
    state_dir="${XDG_STATE_HOME:-$HOME/.local/state}"
  fi

  printf '%s/BremerAI/OpenCodeLauncher/last-%s-project.txt\n' \
    "$state_dir" "$ENVIRONMENT"
}

read_last_project_directory() {
  local state_file="$1"
  local remembered=""

  if [ -f "$state_file" ]; then
    IFS= read -r remembered < "$state_file" || remembered=""
    remembered="${remembered%$'\r'}"

    if [ -n "$remembered" ] && [ -d "$remembered" ]; then
      printf '%s\n' "$remembered"
    fi
  fi
}

save_last_project_directory() {
  local state_file="$1"
  local state_dir
  local tmp_file

  state_dir="$(dirname "$state_file")"
  mkdir -p "$state_dir" 2>/dev/null || return 1
  chmod 700 "$state_dir" 2>/dev/null || true

  tmp_file="${state_file}.tmp.$$"
  printf '%s\n' "$OPENCODE_PROJECT_DIR" > "$tmp_file" || return 1
  mv -f "$tmp_file" "$state_file" || return 1
  chmod 600 "$state_file" 2>/dev/null || true
}

select_windows_project_folder() {
  local state_file="$1"
  local selected_folder
  local initial_windows=""
  local initial_unix=""

  initial_unix="$(read_last_project_directory "$state_file")"

  if [ -n "$initial_unix" ]; then
    initial_windows="$(cygpath -w "$initial_unix" 2>/dev/null)" || initial_windows=""
    echo
    echo "Last project: $initial_unix"
  fi

  echo
  echo "Select the project folder that OpenCode should work with..."
  echo "The picker opens at the last project. You can choose another folder."

  selected_folder="$(
    OPENCODE_INITIAL_PROJECT="$initial_windows" \
      powershell.exe -NoProfile -STA -Command '
        Add-Type -AssemblyName System.Windows.Forms

        $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
        $dialog.Description = "Select the project folder that OpenCode should work with"
        $dialog.ShowNewFolderButton = $true

        $initial = $env:OPENCODE_INITIAL_PROJECT
        if ($initial -and (Test-Path -LiteralPath $initial -PathType Container)) {
          $dialog.SelectedPath = $initial
        }

        if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
          $dialog.SelectedPath
        }
      ' 2>/dev/null |
      tr -d '\r'
  )"

  if [ -z "$selected_folder" ]; then
    echo
    echo "Folder selection was cancelled."
    exit 0
  fi

  OPENCODE_PROJECT_DIR="$(
    cygpath -u "$selected_folder" 2>/dev/null
  )" || {
    echo "ERROR: Could not convert the selected Windows path." >&2
    pause_before_exit
    exit 1
  }
}

select_terminal_project_folder() {
  local state_file="$1"
  local remembered=""
  local entered=""

  remembered="$(read_last_project_directory "$state_file")"

  echo
  if [ -n "$remembered" ]; then
    echo "Last project: $remembered"
    read -r -p "Press Enter to use it, or type another project path: " entered || {
      echo
      echo "Project selection was cancelled."
      exit 0
    }

    if [ -z "$entered" ]; then
      OPENCODE_PROJECT_DIR="$remembered"
    else
      OPENCODE_PROJECT_DIR="$entered"
    fi
  else
    echo "No previous project folder is remembered."
    read -r -p "Project folder [$PWD]: " entered || {
      echo
      echo "Project selection was cancelled."
      exit 0
    }
    OPENCODE_PROJECT_DIR="${entered:-$PWD}"
  fi

  case "$OPENCODE_PROJECT_DIR" in
    ~)
      OPENCODE_PROJECT_DIR="$HOME"
      ;;
    ~/*)
      OPENCODE_PROJECT_DIR="$HOME/${OPENCODE_PROJECT_DIR#~/}"
      ;;
  esac
}

select_project_directory() {
  local state_file

  state_file="$(get_project_state_file)"

  if [ -n "${OPENCODE_PROJECT_DIR:-}" ]; then
    if [ ! -d "$OPENCODE_PROJECT_DIR" ]; then
      echo "ERROR: Project directory does not exist: $OPENCODE_PROJECT_DIR" >&2
      pause_before_exit
      exit 1
    fi

    export OPENCODE_PROJECT_DIR
    save_last_project_directory "$state_file" ||
      echo "WARNING: The last project path could not be saved." >&2
    return 0
  fi

  if is_windows_git_bash; then
    select_windows_project_folder "$state_file"
  else
    select_terminal_project_folder "$state_file"
  fi

  if [ ! -d "$OPENCODE_PROJECT_DIR" ]; then
    echo "ERROR: Project directory does not exist: $OPENCODE_PROJECT_DIR" >&2
    pause_before_exit
    exit 1
  fi

  OPENCODE_PROJECT_DIR="$(
    cd -P "$OPENCODE_PROJECT_DIR" 2>/dev/null && pwd
  )" || {
    echo "ERROR: Could not resolve project directory: $OPENCODE_PROJECT_DIR" >&2
    pause_before_exit
    exit 1
  }

  export OPENCODE_PROJECT_DIR

  save_last_project_directory "$state_file" ||
    echo "WARNING: The last project path could not be saved." >&2
}

validate_required_files() {
  local required

  for required in \
    settings.sh \
    common.sh \
    ssh_key.sh \
    tunnel.sh \
    opencode_config.sh \
    opencode_runtime.sh
  do
    if [ ! -f "$LIB_DIR/$required" ]; then
      echo "ERROR: Missing required file: $LIB_DIR/$required" >&2
      pause_before_exit
      exit 1
    fi
  done
}

select_environment
select_development_profile
select_project_directory
validate_required_files

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

>>>>>>> 3ebe8a0 (Add repository attributes and ignore rules)
main