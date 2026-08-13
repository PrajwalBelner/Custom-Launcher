#!/usr/bin/env bash
# Reusable launcher helpers.

resolve_path() {
  local target="$1"

  if command -v readlink >/dev/null 2>&1; then
    readlink -f "$target" 2>/dev/null && return 0
  fi

  if command -v realpath >/dev/null 2>&1; then
    realpath "$target" 2>/dev/null && return 0
  fi

  case "$target" in
    /*) printf '%s\n' "$target" ;;
    *)  printf '%s/%s\n' "$PWD" "$target" ;;
  esac
}

initialize_runtime_paths() {
  local requested_dir
  local git_root

  requested_dir="$(resolve_path "$PROJECT_DIR")"

  if [ ! -d "$requested_dir" ]; then
    fail "Project directory does not exist: $requested_dir"
  fi

  # Use the Git repository root when the selected folder belongs to one.
  # Otherwise, use the selected project folder itself.
  git_root=""

  if command_exists git; then
    git_root="$(
      git -C "$requested_dir" rev-parse --show-toplevel 2>/dev/null
    )" || git_root=""
  fi

  if [ -n "$git_root" ]; then
    PROJECT_DIR="$(resolve_path "$git_root")"
    echo "Git project detected: $PROJECT_DIR"
  else
    PROJECT_DIR="$requested_dir"
    echo "Using selected project folder: $PROJECT_DIR"
  fi

  if [ ! -d "$PROJECT_DIR" ]; then
    fail "Selected project directory does not exist: $PROJECT_DIR"
  fi

  mkdir -p "$CONTROL_DIR"
  chmod 700 "$CONTROL_DIR" 2>/dev/null || true
}

refresh_path() {
  export PATH="$HOME/.opencode/bin:$HOME/.local/bin:$HOME/bin:$HOME/.npm-global/bin:$PATH"
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

pause_exit() {
  local code="$1"

  echo

  if [ -t 0 ]; then
    read -r -p "Press Enter to close..." _ || true
  fi

  exit "$code"
}

fail() {
  echo "ERROR: $1" >&2
  pause_exit 1
}

log_line() {
  printf '%s\n' "$1" >> "$LOG" 2>/dev/null || true
}

log_header() {
  {
    echo "============================================================"
    echo "AI OpenCode Launcher"
    echo "Started: $(date -Is 2>/dev/null || date)"
    echo "Environment: $ENVIRONMENT_NAME"
    echo "Server: $HOST_USER@$HOST_IP"
    echo "Project: $PROJECT_DIR"
    echo "Ollama: 127.0.0.1:$LOCAL_OLLAMA_PORT -> $HOST_IP:127.0.0.1:$REMOTE_OLLAMA_PORT"
    echo "vLLM:   127.0.0.1:$LOCAL_VLLM_PORT -> $HOST_IP:127.0.0.1:$REMOTE_VLLM_PORT"
    echo "============================================================"
    echo
  } > "$LOG" 2>/dev/null || true
}

show_startup_banner() {
  clear 2>/dev/null || true

  cat <<MSG
============================================================
AI OpenCode Launcher - $ENVIRONMENT_NAME
============================================================
Server:  $HOST_USER@$HOST_IP
Project: $PROJECT_DIR

Ollama tunnel:
  127.0.0.1:$LOCAL_OLLAMA_PORT -> $HOST_IP:127.0.0.1:$REMOTE_OLLAMA_PORT

vLLM tunnel:
  127.0.0.1:$LOCAL_VLLM_PORT -> $HOST_IP:127.0.0.1:$REMOTE_VLLM_PORT

Models:
  Qwen 35B-MoE
  Mistral-24B
  Devstral Coder-2
  Qwen Vision-30B
  Qwen3-14B BF16 (available only while start-vllm is running)

Log: $LOG
============================================================
MSG

  echo
}