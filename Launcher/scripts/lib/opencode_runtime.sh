<<<<<<< HEAD
#!/usr/bin/env bash
# Finds or installs OpenCode, then launches it in the selected project folder.

ensure_opencode_available() {
  refresh_path

  if command_exists opencode; then
    return 0
  fi

  if command_exists curl; then
    echo "OpenCode not found. Trying the official installer..."
    curl -fsSL https://opencode.ai/install | bash >> "$LOG" 2>&1 || true
    refresh_path
  fi

  if command_exists opencode; then
    return 0
  fi

  if command_exists npm; then
    echo "Trying npm fallback for OpenCode..."
    mkdir -p "$HOME/.npm-global"
    npm config set prefix "$HOME/.npm-global" >> "$LOG" 2>&1 || true
    refresh_path
    npm install -g opencode-ai@latest >> "$LOG" 2>&1 || true
    refresh_path
  fi

  command_exists opencode
}

launch_opencode() {
  cd "$PROJECT_DIR" 2>/dev/null ||
    fail "Could not enter Git repository root: $PROJECT_DIR"

  ensure_opencode_available ||
    fail "OpenCode was not found or installed. See $LOG"

  refresh_path

  echo "Starting OpenCode"
  echo "Project root:  $PWD"
  echo "Environment:   $ENVIRONMENT_NAME"
  echo "Default model: Qwen 35B-MoE"
  echo

  set +e
  opencode
  local rc=$?
  set -e

  return "$rc"
}
=======
#!/usr/bin/env bash
# Finds or installs OpenCode, then launches it in the selected project folder.

ensure_opencode_available() {
  refresh_path

  if command_exists opencode; then
    return 0
  fi

  if command_exists curl; then
    echo "OpenCode not found. Trying the official installer..."
    curl -fsSL https://opencode.ai/install | bash >> "$LOG" 2>&1 || true
    refresh_path
  fi

  if command_exists opencode; then
    return 0
  fi

  if command_exists npm; then
    echo "Trying npm fallback for OpenCode..."
    mkdir -p "$HOME/.npm-global"
    npm config set prefix "$HOME/.npm-global" >> "$LOG" 2>&1 || true
    refresh_path
    npm install -g opencode-ai@latest >> "$LOG" 2>&1 || true
    refresh_path
  fi

  command_exists opencode
}

launch_opencode() {
  cd "$PROJECT_DIR" 2>/dev/null ||
    fail "Could not enter Git repository root: $PROJECT_DIR"

  ensure_opencode_available ||
    fail "OpenCode was not found or installed. See $LOG"

  refresh_path

  echo "Starting OpenCode"
  echo "Project root:  $PWD"
  echo "Environment:   $ENVIRONMENT_NAME"
  echo "Default model: Qwen 35B-MoE"
  echo

  set +e
  opencode
  local rc=$?
  set -e

  return "$rc"
<<<<<<< HEAD
}
>>>>>>> dffd222 (Add files via upload)
=======
}
>>>>>>> 3ebe8a0 (Add repository attributes and ignore rules)
