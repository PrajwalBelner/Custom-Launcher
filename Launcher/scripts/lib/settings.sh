<<<<<<< HEAD
#!/usr/bin/env bash
# Environment, SSH key, tunnel, model, and launcher settings.

configure_environment() {
  local environment="${1:-}"

  case "$environment" in
    dev)
      ENVIRONMENT_NAME="Development"
      HOST_IP="192.168.191.61"

      # The Development BAT launcher supplies the selected SSH profile.
      HOST_USER="${OPENCODE_HOST_USER:-}"

      if [ -z "$HOST_USER" ]; then
        echo "ERROR: No Development SSH profile was selected." >&2
        echo "On Windows, use start_ai_opencode_dev.bat." >&2
        exit 2
      fi

      case "$HOST_USER" in
        pgs|dhu|ark|tl)
          ;;
        *)
          echo "ERROR: Unsupported Development SSH profile: $HOST_USER" >&2
          echo "Supported profiles: pgs, dhu, ark, tl" >&2
          exit 2
          ;;
      esac
      ;;

    prd)
      ENVIRONMENT_NAME="Pre-Production"
      HOST_IP="192.168.191.62"
      HOST_USER="prd"
      ;;

    *)
      echo "Usage: $0 dev|prd"
      echo "  dev = selected profile at 192.168.191.61"
      echo "  prd = prd@192.168.191.62"
      exit 2
      ;;
  esac

  # Supported private-key filenames.
  # The launcher uses the first authorized private key found locally.
  KEY_CANDIDATES=(
  "Theju_newkey"
  "id_san_ed25519"
  "id_ed25519"
  "prajwal_dev_prd_ed25519"
  "bimdev_ai_ed25519"
  "bremer_prd_opencode_ed25519"
)

  # The selected private-key path is assigned by ssh_key.sh.
  KEY=""

  # Client-side ports.
  # Non-default ports avoid collisions with local Ollama or vLLM services.
  LOCAL_OLLAMA_PORT="11435"
  LOCAL_VLLM_PORT="18000"

  # Server-side API ports.
  REMOTE_OLLAMA_PORT="11434"
  REMOTE_VLLM_PORT="8000"

  WAIT_SECONDS="30"

  # Ollama API through the local SSH tunnel.
  OLLAMA_API_BASE="http://127.0.0.1:${LOCAL_OLLAMA_PORT}"
  OLLAMA_OPENAI_BASE="${OLLAMA_API_BASE}/v1"
  OLLAMA_VERSION_URL="${OLLAMA_API_BASE}/api/version"
  OLLAMA_MODELS_URL="${OLLAMA_API_BASE}/api/tags"

  # vLLM API through the local SSH tunnel.
  VLLM_API_BASE="http://127.0.0.1:${LOCAL_VLLM_PORT}/v1"
  VLLM_HEALTH_URL="http://127.0.0.1:${LOCAL_VLLM_PORT}/health"
  VLLM_MODELS_URL="${VLLM_API_BASE}/models"

  # Default OpenCode model.
  DEFAULT_MODEL_ID="local/qwen35B-MoE:latest"

  # Use the project directory supplied by the Windows launcher.
  # Otherwise, preserve the directory from which Bash was started.
  PROJECT_DIR="${OPENCODE_PROJECT_DIR:-$PWD}"

  # Convert a Windows path such as C:\StructHelpers into the Git Bash
  # path format, such as /c/StructHelpers.
  if command -v cygpath >/dev/null 2>&1; then
    case "$PROJECT_DIR" in
      [A-Za-z]:\\*|[A-Za-z]:/*)
        PROJECT_DIR="$(cygpath -u "$PROJECT_DIR")"
        ;;
    esac
  fi

  # Keep logs separate by environment and SSH profile.
  LOG="$SCRIPT_DIR/ai_opencode_${environment}_${HOST_USER}.log"

  # Client SSH and tunnel-control paths.
  SSH_DIR="$HOME/.ssh"
  CONTROL_DIR="$HOME/.cache/ai-opencode-launcher"

  # Include the SSH profile in the socket name so profiles do not reuse
  # another user's Development control connection.
  CONTROL_SOCKET="$CONTROL_DIR/ssh-${environment}-${HOST_USER}.sock"
=======
#!/usr/bin/env bash
# Environment, SSH key, tunnel, model, and launcher settings.

configure_environment() {
  case "${1:-}" in
    dev)
      ENVIRONMENT_NAME="Development"
      HOST_IP="192.168.191.61"
      HOST_USER="pgs"
      ;;

    prd)
      ENVIRONMENT_NAME="Pre-Production"
      HOST_IP="192.168.191.62"
      HOST_USER="prd"
      ;;

    *)
      echo "Usage: $0 dev|prd"
      echo "  dev = pgs@192.168.191.61"
      echo "  prd = prd@192.168.191.62"
      exit 2
      ;;
  esac

  # Supported private-key filenames.
  # The launcher uses the first authorized key found on the client.
  KEY_CANDIDATES=(
    "prajwal_dev_prd_ed25519"
    "bimdev_ai_ed25519"
    "bremer_prd_opencode_ed25519"
  )

  # The selected key path is assigned by ssh_key.sh.
  KEY=""

  # Client-side ports.
  # Non-default ports avoid collisions with any local Ollama or vLLM service.
  LOCAL_OLLAMA_PORT="11435"
  LOCAL_VLLM_PORT="18000"

  # Server-side API ports.
  REMOTE_OLLAMA_PORT="11434"
  REMOTE_VLLM_PORT="8000"

  WAIT_SECONDS="30"

  # Ollama API through the local SSH tunnel.
  OLLAMA_API_BASE="http://127.0.0.1:${LOCAL_OLLAMA_PORT}"
  OLLAMA_OPENAI_BASE="${OLLAMA_API_BASE}/v1"
  OLLAMA_VERSION_URL="${OLLAMA_API_BASE}/api/version"
  OLLAMA_MODELS_URL="${OLLAMA_API_BASE}/api/tags"

  # vLLM API through the local SSH tunnel.
  VLLM_API_BASE="http://127.0.0.1:${LOCAL_VLLM_PORT}/v1"
  VLLM_HEALTH_URL="http://127.0.0.1:${LOCAL_VLLM_PORT}/health"
  VLLM_MODELS_URL="${VLLM_API_BASE}/models"

  # Default OpenCode model.
  DEFAULT_MODEL_ID="local/qwen35B-MoE:latest"

  # Use the current folder as the OpenCode project unless overridden.
  PROJECT_DIR="${OPENCODE_PROJECT_DIR:-$PWD}"

  # Launcher log file.
  LOG="$SCRIPT_DIR/ai_opencode_${1}.log"

  # Client SSH and tunnel-control paths.
  SSH_DIR="$HOME/.ssh"
  CONTROL_DIR="$HOME/.cache/ai-opencode-launcher"
  CONTROL_SOCKET="$CONTROL_DIR/ssh-${1}.sock"
>>>>>>> dffd222 (Add files via upload)
}