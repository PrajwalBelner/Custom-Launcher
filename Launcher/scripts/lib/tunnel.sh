<<<<<<< HEAD
#!/usr/bin/env bash
# SSH tunnel lifecycle for Ollama and optional vLLM.

ssh_common_options() {
  printf '%s\n' \
    -i "$KEY" \
    -o BatchMode=yes \
    -o IdentitiesOnly=yes \
    -o ConnectTimeout=10 \
    -o StrictHostKeyChecking=accept-new \
    -o ServerAliveInterval=30 \
    -o ServerAliveCountMax=3
}

ensure_ssh_access() {
  echo "Checking SSH access to $HOST_USER@$HOST_IP..."

  if ! ssh -i "$KEY" \
      -o BatchMode=yes \
      -o IdentitiesOnly=yes \
      -o ConnectTimeout=10 \
      -o StrictHostKeyChecking=accept-new \
      "$HOST_USER@$HOST_IP" true >> "$LOG" 2>&1; then
    fail "SSH connection failed for $HOST_USER@$HOST_IP. See $LOG"
  fi

  echo "SSH connection ready."
}

control_master_alive() {
  [ -S "$CONTROL_SOCKET" ] || return 1
  ssh -S "$CONTROL_SOCKET" -O check "$HOST_USER@$HOST_IP" >/dev/null 2>&1
}

stop_tunnels() {
  if control_master_alive; then
    ssh -S "$CONTROL_SOCKET" -O exit \
      "$HOST_USER@$HOST_IP" >/dev/null 2>&1 || true
  fi

  rm -f "$CONTROL_SOCKET" >/dev/null 2>&1 || true
}

port_is_free() {
  local port="$1"

  if command_exists ss; then
    ! ss -ltn 2>/dev/null |
      awk '{print $4}' |
      grep -Eq "(^|:)$port$"
    return
  fi

  if command_exists netstat.exe; then
    ! netstat.exe -ano 2>/dev/null |
      tr -d '\r' |
      grep -Eq "[.:]$port[[:space:]].*LISTENING"
    return
  fi

  return 0
}

start_tunnels() {
  stop_tunnels

  port_is_free "$LOCAL_OLLAMA_PORT" ||
    fail "Local port $LOCAL_OLLAMA_PORT is already in use. Close the conflicting application and retry."

  port_is_free "$LOCAL_VLLM_PORT" ||
    fail "Local port $LOCAL_VLLM_PORT is already in use. Close the conflicting application and retry."

  echo "Starting SSH tunnels..."

  ssh -M -S "$CONTROL_SOCKET" -fN \
    -i "$KEY" \
    -o BatchMode=yes \
    -o IdentitiesOnly=yes \
    -o ConnectTimeout=10 \
    -o ExitOnForwardFailure=yes \
    -o StrictHostKeyChecking=accept-new \
    -o ServerAliveInterval=30 \
    -o ServerAliveCountMax=3 \
    -L "127.0.0.1:${LOCAL_OLLAMA_PORT}:127.0.0.1:${REMOTE_OLLAMA_PORT}" \
    -L "127.0.0.1:${LOCAL_VLLM_PORT}:127.0.0.1:${REMOTE_VLLM_PORT}" \
    "$HOST_USER@$HOST_IP" >> "$LOG" 2>&1 ||
    fail "SSH tunnel creation failed. See $LOG"

  control_master_alive ||
    fail "SSH tunnel did not remain active. See $LOG"

  echo "SSH tunnels ready."
}

wait_for_url() {
  local url="$1"
  local seconds="$2"
  local i=1

  while [ "$i" -le "$seconds" ]; do
    if curl --fail --silent --max-time 3 "$url" >/dev/null 2>&1; then
      return 0
    fi

    sleep 1
    i=$((i + 1))
  done

  return 1
}

check_ollama_models() {
  local response

  response="$(
    curl --fail --silent --max-time 10 "$OLLAMA_MODELS_URL" 2>/dev/null
  )" || return 1

  for model in \
    'qwen35B-MoE:latest' \
    'mistral32-q8:latest' \
    'devstral-small-2:24b' \
    'qwen3-vl:30b'
  do
    printf '%s' "$response" |
      grep -F "$model" >/dev/null 2>&1 ||
      return 1
  done
}

check_backends() {
  echo

  if wait_for_url "$OLLAMA_VERSION_URL" "$WAIT_SECONDS"; then
    echo "Ollama API ready: $OLLAMA_OPENAI_BASE"

    if check_ollama_models; then
      echo "All four Ollama models are visible."
    else
      echo "WARNING: Ollama is ready, but not all four expected models were found."
    fi
  else
    fail "Ollama API did not become ready through the tunnel."
  fi

  if curl --fail --silent --max-time 5 \
      "$VLLM_HEALTH_URL" >/dev/null 2>&1; then
    echo "vLLM API ready:   $VLLM_API_BASE"
  else
    echo "vLLM API offline: Qwen3-14B BF16 will work after start-vllm is run on the server."
  fi

  echo
}
=======
#!/usr/bin/env bash
ssh_common_options() {
  printf '%s\n' \
    -i "$KEY" \
    -o BatchMode=yes \
    -o IdentitiesOnly=yes \
    -o ConnectTimeout=10 \
    -o StrictHostKeyChecking=accept-new \
    -o ServerAliveInterval=30 \
    -o ServerAliveCountMax=3
}

ensure_ssh_access() {
  echo "Checking SSH access to $HOST_USER@$HOST_IP..."

  if ! ssh -i "$KEY" \
      -o BatchMode=yes \
      -o IdentitiesOnly=yes \
      -o ConnectTimeout=10 \
      -o StrictHostKeyChecking=accept-new \
      "$HOST_USER@$HOST_IP" true >> "$LOG" 2>&1; then
    fail "SSH connection failed for $HOST_USER@$HOST_IP. See $LOG"
  fi

  echo "SSH connection ready."
}

control_master_alive() {
  [ -S "$CONTROL_SOCKET" ] || return 1
  ssh -S "$CONTROL_SOCKET" -O check \
    "$HOST_USER@$HOST_IP" >/dev/null 2>&1
}

tunnel_state_file() {
  printf '%s/active-tunnel.state\n' "$CONTROL_DIR"
}

read_tunnel_state() {
  local state_file
  local name
  local value

  ACTIVE_TUNNEL_HOST_IP=""
  ACTIVE_TUNNEL_HOST_USER=""
  ACTIVE_TUNNEL_OLLAMA_PORT=""
  ACTIVE_TUNNEL_VLLM_PORT=""
  ACTIVE_TUNNEL_SOCKET=""

  state_file="$(tunnel_state_file)"
  [ -f "$state_file" ] || return 1

  while IFS='=' read -r name value; do
    case "$name" in
      HOST_IP)
        ACTIVE_TUNNEL_HOST_IP="$value"
        ;;
      HOST_USER)
        ACTIVE_TUNNEL_HOST_USER="$value"
        ;;
      LOCAL_OLLAMA_PORT)
        ACTIVE_TUNNEL_OLLAMA_PORT="$value"
        ;;
      LOCAL_VLLM_PORT)
        ACTIVE_TUNNEL_VLLM_PORT="$value"
        ;;
      CONTROL_SOCKET)
        ACTIVE_TUNNEL_SOCKET="$value"
        ;;
    esac
  done < "$state_file"

  [ -n "$ACTIVE_TUNNEL_HOST_IP" ]
}

write_tunnel_state() {
  local state_file
  local tmp_file

  state_file="$(tunnel_state_file)"
  tmp_file="${state_file}.tmp.$$"

  {
    printf 'HOST_IP=%s\n' "$HOST_IP"
    printf 'HOST_USER=%s\n' "$HOST_USER"
    printf 'LOCAL_OLLAMA_PORT=%s\n' "$LOCAL_OLLAMA_PORT"
    printf 'LOCAL_VLLM_PORT=%s\n' "$LOCAL_VLLM_PORT"
    printf 'CONTROL_SOCKET=%s\n' "$CONTROL_SOCKET"
  } > "$tmp_file"

  mv -f "$tmp_file" "$state_file"
  chmod 600 "$state_file" 2>/dev/null || true
}

existing_tunnel_matches_request() {
  read_tunnel_state || return 1

  [ "$ACTIVE_TUNNEL_HOST_IP" = "$HOST_IP" ] || return 1
  [ "$ACTIVE_TUNNEL_OLLAMA_PORT" = "$LOCAL_OLLAMA_PORT" ] || return 1
  [ "$ACTIVE_TUNNEL_VLLM_PORT" = "$LOCAL_VLLM_PORT" ] || return 1

  curl --fail --silent --max-time 3 \
    "$OLLAMA_VERSION_URL" >/dev/null 2>&1
}

stop_tunnels() {
  local state_file

  if [ "${FORCE_TUNNEL_STOP:-0}" != "1" ]; then
    return 0
  fi

  state_file="$(tunnel_state_file)"

  if read_tunnel_state && [ -n "$ACTIVE_TUNNEL_SOCKET" ]; then
    if [ -S "$ACTIVE_TUNNEL_SOCKET" ]; then
      ssh -S "$ACTIVE_TUNNEL_SOCKET" -O exit \
        "$ACTIVE_TUNNEL_HOST_USER@$ACTIVE_TUNNEL_HOST_IP" \
        >/dev/null 2>&1 || true
    fi

    rm -f "$ACTIVE_TUNNEL_SOCKET" >/dev/null 2>&1 || true
  fi

  rm -f "$CONTROL_SOCKET" "$state_file" >/dev/null 2>&1 || true
}

port_is_free() {
  local port="$1"

  if command_exists ss; then
    ! ss -ltn 2>/dev/null |
      awk '{print $4}' |
      grep -Eq "(^|:)$port$"
    return
  fi

  if command_exists netstat.exe; then
    ! netstat.exe -ano 2>/dev/null |
      tr -d '\r' |
      grep -Eq "[.:]$port[[:space:]].*LISTENING"
    return
  fi

  return 0
}

start_tunnels() {
  local ollama_port_free=0
  local vllm_port_free=0

  mkdir -p "$CONTROL_DIR"
  chmod 700 "$CONTROL_DIR" 2>/dev/null || true

  if control_master_alive &&
     curl --fail --silent --max-time 3 \
       "$OLLAMA_VERSION_URL" >/dev/null 2>&1; then
    echo "Existing OpenCode SSH tunnel is healthy."
    echo "Reusing local ports $LOCAL_OLLAMA_PORT and $LOCAL_VLLM_PORT."
    return 0
  fi

  port_is_free "$LOCAL_OLLAMA_PORT" && ollama_port_free=1
  port_is_free "$LOCAL_VLLM_PORT" && vllm_port_free=1

  if [ "$ollama_port_free" -ne 1 ] || [ "$vllm_port_free" -ne 1 ]; then
    if existing_tunnel_matches_request; then
      echo "Existing OpenCode SSH tunnel detected."
      echo "Reusing local ports $LOCAL_OLLAMA_PORT and $LOCAL_VLLM_PORT."
      return 0
    fi

    fail "Local port $LOCAL_OLLAMA_PORT or $LOCAL_VLLM_PORT is occupied by another application or a different server tunnel."
  fi
  rm -f "$CONTROL_SOCKET" >/dev/null 2>&1 || true

  echo "Starting SSH tunnels..."

  ssh -M -S "$CONTROL_SOCKET" -fN \
    -i "$KEY" \
    -o BatchMode=yes \
    -o IdentitiesOnly=yes \
    -o ConnectTimeout=10 \
    -o ExitOnForwardFailure=yes \
    -o StrictHostKeyChecking=accept-new \
    -o ServerAliveInterval=30 \
    -o ServerAliveCountMax=3 \
    -L "127.0.0.1:${LOCAL_OLLAMA_PORT}:127.0.0.1:${REMOTE_OLLAMA_PORT}" \
    -L "127.0.0.1:${LOCAL_VLLM_PORT}:127.0.0.1:${REMOTE_VLLM_PORT}" \
    "$HOST_USER@$HOST_IP" >> "$LOG" 2>&1 ||
    fail "SSH tunnel creation failed. See $LOG"

  control_master_alive ||
    fail "SSH tunnel did not remain active. See $LOG"

  write_tunnel_state ||
    fail "SSH tunnel started, but its shared state could not be saved."

  echo "SSH tunnels ready."
}

wait_for_url() {
  local url="$1"
  local seconds="$2"
  local i=1

  while [ "$i" -le "$seconds" ]; do
    if curl --fail --silent --max-time 3 "$url" >/dev/null 2>&1; then
      return 0
    fi

    sleep 1
    i=$((i + 1))
  done

  return 1
}

check_ollama_models() {
  local response

  response="$(
    curl --fail --silent --max-time 10 "$OLLAMA_MODELS_URL" 2>/dev/null
  )" || return 1

  for model in \
    'qwen35B-MoE:latest' \
    'mistral32-q8:latest' \
    'devstral-small-2:24b' \
    'qwen3-vl:30b'
  do
    printf '%s' "$response" |
      grep -F "$model" >/dev/null 2>&1 ||
      return 1
  done
}

check_backends() {
  echo

  if wait_for_url "$OLLAMA_VERSION_URL" "$WAIT_SECONDS"; then
    echo "Ollama API ready: $OLLAMA_OPENAI_BASE"

    if check_ollama_models; then
      echo "All four Ollama models are visible."
    else
      echo "WARNING: Ollama is ready, but not all four expected models were found."
    fi
  else
    fail "Ollama API did not become ready through the tunnel."
  fi

  if curl --fail --silent --max-time 5 \
      "$VLLM_HEALTH_URL" >/dev/null 2>&1; then
    echo "vLLM API ready:   $VLLM_API_BASE"
  else
    echo "vLLM API offline: Qwen3-14B BF16 will work after start-vllm is run on the server."
  fi

  echo
}
>>>>>>> dffd222 (Add files via upload)
