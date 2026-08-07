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