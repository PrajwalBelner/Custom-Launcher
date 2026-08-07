#!/usr/bin/env bash
# Finds an authorized Development/Pre-Production SSH private key.
# Supports Git Bash, WSL, and Linux.
#
# KEY_CANDIDATES must be defined in settings.sh.

normalize_private_key() {
  local tmp_key="${KEY}.tmp.$$"

  # Remove Windows CRLF characters from copied private keys.
  tr -d '\r' < "$KEY" > "$tmp_key"
  mv "$tmp_key" "$KEY"

  chmod 600 "$KEY"

  if [ -f "$KEY.pub" ]; then
    chmod 644 "$KEY.pub" 2>/dev/null || true
  fi
}

get_windows_ssh_directory() {
  # Git Bash usually provides USERPROFILE as a Windows path.
  if [ -n "${USERPROFILE:-}" ] &&
     command -v cygpath >/dev/null 2>&1; then
    cygpath -u "$USERPROFILE/.ssh" 2>/dev/null || true
    return
  fi

  # Git Bash fallback using the Windows username.
  if [ -n "${USERNAME:-}" ] &&
     [ -d "/c/Users/$USERNAME/.ssh" ]; then
    printf '/c/Users/%s/.ssh\n' "$USERNAME"
    return
  fi

  # WSL fallback using the Windows username.
  if [ -n "${USERNAME:-}" ] &&
     [ -d "/mnt/c/Users/$USERNAME/.ssh" ]; then
    printf '/mnt/c/Users/%s/.ssh\n' "$USERNAME"
    return
  fi
}

find_or_install_key() {
  mkdir -p "$SSH_DIR"
  chmod 700 "$SSH_DIR"

  local key_name
  local base
  local candidate
  local destination
  local windows_ssh_dir

  windows_ssh_dir="$(get_windows_ssh_directory)"

  for key_name in "${KEY_CANDIDATES[@]}"; do
    destination="$SSH_DIR/$key_name"

    # First check whether this key is already installed.
    if [ -f "$destination" ]; then
      KEY="$destination"
      normalize_private_key

      echo "Using SSH key: $KEY"
      return 0
    fi

    # Search approved source locations.
    for base in \
      "$SCRIPT_DIR/keys" \
      "$SCRIPT_DIR" \
      "$PWD/keys" \
      "$PWD" \
      "$HOME/Downloads/keys" \
      "$HOME/Downloads" \
      "$windows_ssh_dir"
    do
      [ -n "$base" ] || continue

      candidate="$base/$key_name"

      if [ -f "$candidate" ]; then
        KEY="$destination"

        # Copy the private key into the current shell user's SSH folder.
        cp -f "$candidate" "$KEY"

        # Copy the public-key file when it is available.
        if [ -f "$candidate.pub" ]; then
          cp -f "$candidate.pub" "$KEY.pub"
        fi

        normalize_private_key

        echo "SSH key installed from: $candidate"
        echo "Using SSH key: $KEY"
        return 0
      fi
    done
  done

  echo "ERROR: No supported SSH private key was found."
  echo
  echo "Supported private-key filenames:"

  for key_name in "${KEY_CANDIDATES[@]}"; do
    echo "  $key_name"
  done

  echo
  echo "Place one authorized private key in:"
  echo "  $SSH_DIR"
  echo "  $SCRIPT_DIR/keys"
  echo "  $HOME/Downloads"
  echo "  The current Windows user's .ssh folder"

  if [ -n "$windows_ssh_dir" ]; then
    echo
    echo "Detected Windows SSH folder:"
    echo "  $windows_ssh_dir"
  fi

  echo
  echo "Do not place only the .pub file on the client."
  echo "The client requires the private key without the .pub extension."

  return 1
}