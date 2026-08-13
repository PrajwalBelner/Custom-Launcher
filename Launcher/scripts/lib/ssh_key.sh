<<<<<<< HEAD
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
=======
#!/usr/bin/env bash
# Supports Git Bash, WSL, and Linux.

normalize_private_key() {
  local tmp_key="${KEY}.tmp.$$"

  tr -d '\r' < "$KEY" > "$tmp_key"
  mv "$tmp_key" "$KEY"
  chmod 600 "$KEY" 2>/dev/null || true

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

is_private_key_file() {
  local candidate="$1"
  local first_line

  [ -f "$candidate" ] || return 1

  case "$candidate" in
    *.pub|*/config|*/known_hosts|*/known_hosts.old|*/authorized_keys|*.log|*.bak|*.tmp)
      return 1
      ;;
  esac

  IFS= read -r first_line < "$candidate" || return 1
  first_line="${first_line%$'\r'}"

  case "$first_line" in
    "-----BEGIN OPENSSH PRIVATE KEY-----"|\
    "-----BEGIN RSA PRIVATE KEY-----"|\
    "-----BEGIN EC PRIVATE KEY-----"|\
    "-----BEGIN DSA PRIVATE KEY-----"|\
    "-----BEGIN PRIVATE KEY-----"|\
    "-----BEGIN ENCRYPTED PRIVATE KEY-----")
      return 0
      ;;
  esac

  return 1
}

fingerprint_from_public_key() {
  ssh-keygen -lf "$1" -E sha256 2>/dev/null |
    awk 'NR == 1 { print $2 }'
}

fingerprint_from_private_key() {
  local candidate="$1"
  local public_key=""
  local fingerprint=""

  # -P "" prevents ssh-keygen from prompting for a passphrase. This handles
  public_key="$(ssh-keygen -y -P "" -f "$candidate" 2>/dev/null)" || true

  if [ -n "$public_key" ]; then
    fingerprint="$(
      printf '%s\n' "$public_key" |
        ssh-keygen -lf - -E sha256 2>/dev/null |
        awk 'NR == 1 { print $2 }'
    )"
  elif [ -f "$candidate.pub" ]; then
    fingerprint="$(fingerprint_from_public_key "$candidate.pub")"
  fi

  [ -n "$fingerprint" ] || return 1
  printf '%s\n' "$fingerprint"
}

fingerprint_is_approved() {
  local fingerprint="$1"
  local approved

  for approved in "${APPROVED_KEY_FINGERPRINTS[@]}"; do
    if [ "$fingerprint" = "$approved" ]; then
      return 0
    fi
  done

  return 1
}

install_selected_key() {
  local candidate="$1"
  local destination
  local base
  local safe_fingerprint

  # A key already in the active SSH directory can be used directly.
  case "$candidate" in
    "$SSH_DIR"/*)
      KEY="$candidate"
      normalize_private_key
      return 0
      ;;
  esac

  base="$(basename "$candidate")"
  destination="$SSH_DIR/$base"

  if [ -e "$destination" ] && ! cmp -s "$candidate" "$destination"; then
    safe_fingerprint="${KEY_FINGERPRINT#SHA256:}"
    safe_fingerprint="$(printf '%s' "$safe_fingerprint" | tr '/+' '__' | cut -c1-16)"
    destination="$SSH_DIR/opencode_${safe_fingerprint}"
  fi

  cp -f "$candidate" "$destination"
  KEY="$destination"

  if [ -f "$candidate.pub" ]; then
    cp -f "$candidate.pub" "$KEY.pub"
  fi

  normalize_private_key
}

find_or_install_key() {
  mkdir -p "$SSH_DIR"
  chmod 700 "$SSH_DIR" 2>/dev/null || true

  local windows_ssh_dir
  local search_dir
  local candidate
  local fingerprint
  local encrypted_without_public=0
  local -a search_dirs
  local -A searched_dirs
  local -A searched_files

  if [ "${#APPROVED_KEY_FINGERPRINTS[@]}" -eq 0 ]; then
    echo "ERROR: No approved SSH fingerprints are configured for $ENVIRONMENT_NAME." >&2
    return 1
  fi

  windows_ssh_dir="$(get_windows_ssh_directory)"

  search_dirs=(
    "$SSH_DIR"
    "$windows_ssh_dir"
    "$SCRIPT_DIR/keys"
    "$SCRIPT_DIR"
    "$PWD/keys"
    "$PWD"
    "$HOME/Downloads/keys"
    "$HOME/Downloads"
  )

  for search_dir in "${search_dirs[@]}"; do
    [ -n "$search_dir" ] || continue
    [ -d "$search_dir" ] || continue

    search_dir="$(cd -P "$search_dir" 2>/dev/null && pwd)" || continue
    [ -z "${searched_dirs[$search_dir]+x}" ] || continue
    searched_dirs["$search_dir"]=1

    while IFS= read -r -d '' candidate; do
      [ -z "${searched_files[$candidate]+x}" ] || continue
      searched_files["$candidate"]=1

      is_private_key_file "$candidate" || continue

      fingerprint="$(fingerprint_from_private_key "$candidate")" || {
        if [ ! -f "$candidate.pub" ]; then
          encrypted_without_public=$((encrypted_without_public + 1))
        fi
        continue
      }

      fingerprint_is_approved "$fingerprint" || continue

      KEY_FINGERPRINT="$fingerprint"
      install_selected_key "$candidate" || {
        echo "ERROR: Could not prepare approved SSH key: $candidate" >&2
        return 1
      }

      echo "Using approved SSH key: $KEY"
      echo "SSH key fingerprint: $KEY_FINGERPRINT"
      return 0
    done < <(find "$search_dir" -maxdepth 1 -type f -print0 2>/dev/null)
  done

  echo "ERROR: No approved SSH private key was found for $ENVIRONMENT_NAME."
  echo
  echo "The launcher checked private keys in:"
  for search_dir in "${search_dirs[@]}"; do
    [ -n "$search_dir" ] && echo "  $search_dir"
  done

  echo
  echo "Approved fingerprints for $ENVIRONMENT_NAME:"
  for fingerprint in "${APPROVED_KEY_FINGERPRINTS[@]}"; do
    echo "  $fingerprint"
  done

  if [ "$encrypted_without_public" -gt 0 ]; then
    echo
    echo "One or more passphrase-protected keys had no companion .pub file."
    echo "Create the matching .pub file once, then run the launcher again:"
    echo '  ssh-keygen -y -f "$HOME/.ssh/PRIVATE_KEY_NAME" > "$HOME/.ssh/PRIVATE_KEY_NAME.pub"'
    echo "The command will ask for that key's passphrase."
  fi

  echo
  echo "Do not copy or share private keys. Only public keys should be added"
  echo "to the server and their SHA256 fingerprints to settings.sh."

  return 1
<<<<<<< HEAD
>>>>>>> dffd222 (Add files via upload)
}
=======
}
>>>>>>> 3ebe8a0 (Add repository attributes and ignore rules)
