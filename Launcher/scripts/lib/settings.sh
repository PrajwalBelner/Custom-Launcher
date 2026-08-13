#!/usr/bin/env bash
# Environment, approved SSH identities, tunnel, model, and launcher settings.

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

  # Development fingerprints grouped by SSH profile.
  APPROVED_DEV_PGS_FINGERPRINTS=(
    # Prajwal workstation
    "SHA256:Rh58dJhxw2uLUHWEg4e/mHMn8MFKy1ahld9miunDYJ0"

    # Prajwal Development/Pre-Production key
    "SHA256:5KExuehhLYg799Ypgym28VvLLIvjqmd1GK+5c8Usteo"

    # Conference room Development key
    "SHA256:7QnlBYkRvI6K54y2H30FEzeuYAIt2azzupk1bpSjZIs"

    # Dhu
    "SHA256:LTkS2m+MR0tBiWQIAjEkuwlbWiv9owCkhwveV2xlUVw"

    # San Development machine
    "SHA256:q+4dMOQPnE1xPKEGrRbv2ZQqvtGtuM4+TTaf2qeqwyg"
  )

  APPROVED_DEV_DHU_FINGERPRINTS=(
    # Dhu local AI machine
    "SHA256:lmM+dQbqDHJJdVTNd2kazLn4ZevqMtv6dgi9HyA77uA"

    # Dhu / boss workstation
    "SHA256:LTkS2m+MR0tBiWQIAjEkuwlbWiv9owCkhwveV2xlUVw"

    # Development dhu profile
    "SHA256:pntQEmHqxthupA9g2DCPNUbwgU/2TDWEjl7Q1w50kEo"
  )

  APPROVED_DEV_ARK_FINGERPRINTS=(
    # Ark
    "SHA256:0pHbP2vmyfyoSUpHQctyzQUCGnV7UnN21oKW9r/IODY"
  )

  APPROVED_DEV_TL_FINGERPRINTS=(
      # Teju
    "SHA256:y1AIyYPOhVH5JDOyjpHaloibQd95dbmRqxX5CzRNxdA"
  )

  # Pre-Production fingerprints.
  APPROVED_PRD_FINGERPRINTS=(
    # Ark
    "SHA256:0pHbP2vmyfyoSUpHQctyzQUCGnV7UnN21oKW9r/IODY"

    # Teju
    "SHA256:y1AIyYPOhVH5JDOyjpHaloibQd95dbmRqxX5CzRNxdA"

    # Prajwal workstation
    "SHA256:Rh58dJhxw2uLUHWEg4e/mHMn8MFKy1ahld9miunDYJ0"

    # Prajwal Development/Pre-Production key
    "SHA256:5KExuehhLYg799Ypgym28VvLLIvjqmd1GK+5c8Usteo"

    # Dhu / boss workstation
    "SHA256:LTkS2m+MR0tBiWQIAjEkuwlbWiv9owCkhwveV2xlUVw"

    # Dhu local AI machine
    "SHA256:lmM+dQbqDHJJdVTNd2kazLn4ZevqMtv6dgi9HyA77uA"

    # San remote machine
    "SHA256:ANk/gW8hlWfFe8HN+l3UYUR0m1GGftTeX5CIWacX+G0"
  )

  if [ "$environment" = "dev" ]; then
    case "$HOST_USER" in
      pgs)
        APPROVED_KEY_FINGERPRINTS=(
          "${APPROVED_DEV_PGS_FINGERPRINTS[@]}"
        )
        ;;

      dhu)
        APPROVED_KEY_FINGERPRINTS=(
          "${APPROVED_DEV_DHU_FINGERPRINTS[@]}"
        )
        ;;

      ark)
        APPROVED_KEY_FINGERPRINTS=(
          "${APPROVED_DEV_ARK_FINGERPRINTS[@]}"
        )
        ;;

      tl)
        APPROVED_KEY_FINGERPRINTS=(
          "${APPROVED_DEV_TL_FINGERPRINTS[@]}"
        )
        ;;
    esac
  else
    APPROVED_KEY_FINGERPRINTS=(
      "${APPROVED_PRD_FINGERPRINTS[@]}"
    )
  fi

  if [ "${#APPROVED_KEY_FINGERPRINTS[@]}" -eq 0 ]; then
    echo "ERROR: No approved SSH fingerprints are configured for:" >&2
    echo "  $HOST_USER@$HOST_IP" >&2
    exit 2
  fi

  KEY=""
  KEY_FINGERPRINT=""

  # Client-side ports.
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

  DEFAULT_MODEL_ID="local/qwen35B-MoE:latest"
  PROJECT_DIR="${OPENCODE_PROJECT_DIR:-$PWD}"

  if command -v cygpath >/dev/null 2>&1; then
    case "$PROJECT_DIR" in
      [A-Za-z]:\\*|[A-Za-z]:/*)
        PROJECT_DIR="$(cygpath -u "$PROJECT_DIR")"
        ;;
    esac
  fi

  LOG="$SCRIPT_DIR/ai_opencode_${environment}_${HOST_USER}.log"
  SSH_DIR="$HOME/.ssh"
  CONTROL_DIR="$HOME/.cache/ai-opencode-launcher"
  CONTROL_SOCKET="$CONTROL_DIR/ssh-${environment}-${HOST_USER}.sock"
}