<<<<<<< HEAD
#!/usr/bin/env bash
# Writes the shared OpenCode provider configuration.

write_opencode_config() {
  local config_dir="$HOME/.config/opencode"
  local config_path="$config_dir/opencode.json"
  local backup_path

  mkdir -p "$config_dir"
  chmod 700 "$config_dir" 2>/dev/null || true

  if [ -f "$config_path" ]; then
    backup_path="$config_path.backup.$(date +%Y%m%d-%H%M%S)"
    cp -f "$config_path" "$backup_path"
  fi

  cat > "$config_path" <<JSON
{
  "\$schema": "https://opencode.ai/config.json",
  "model": "local/qwen35B-MoE:latest",
  "provider": {
    "local": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Local",
      "options": {
        "baseURL": "$OLLAMA_OPENAI_BASE",
        "apiKey": "ollama"
      },
      "models": {
        "qwen35B-MoE:latest": {
          "name": "Qwen 35B-MoE"
        },
        "mistral32-q8:latest": {
          "name": "Mistral-24B"
        },
        "devstral-small-2:24b": {
          "name": "Devstral Coder-2"
        },
        "qwen3-vl:30b": {
          "name": "Qwen Vision-30B"
        }
      }
    },
    "vllm": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "vLLM",
      "options": {
        "baseURL": "$VLLM_API_BASE",
        "apiKey": "local"
      },
      "models": {
        "qwen3-14b-bf16": {
          "name": "Qwen3-14B BF16",
          "limit": {
            "context": 16384,
            "output": 2048
          }
        }
      }
    }
  }
}
JSON

  chmod 600 "$config_path" 2>/dev/null || true
  rm -f "$config_dir/tui.json" >/dev/null 2>&1 || true

  if command_exists python3 && python3 --version >/dev/null 2>&1; then
    python3 -m json.tool "$config_path" >/dev/null ||
      fail "Generated OpenCode configuration is invalid."
  fi

  printf '%s\n' "$config_path"
}
=======
#!/usr/bin/env bash
# Writes the shared OpenCode provider configuration.

write_opencode_config() {
  local config_dir="$HOME/.config/opencode"
  local config_path="$config_dir/opencode.json"
  local backup_path

  mkdir -p "$config_dir"
  chmod 700 "$config_dir" 2>/dev/null || true

  if [ -f "$config_path" ]; then
    backup_path="$config_path.backup.$(date +%Y%m%d-%H%M%S)"
    cp -f "$config_path" "$backup_path"
  fi

  cat > "$config_path" <<JSON
{
  "\$schema": "https://opencode.ai/config.json",
  "model": "local/qwen35B-MoE:latest",
  "provider": {
    "local": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Local",
      "options": {
        "baseURL": "$OLLAMA_OPENAI_BASE",
        "apiKey": "ollama"
      },
      "models": {
        "qwen35B-MoE:latest": {
          "name": "Qwen 35B-MoE"
        },
        "mistral32-q8:latest": {
          "name": "Mistral-24B"
        },
        "devstral-small-2:24b": {
          "name": "Devstral Coder-2"
        },
        "qwen3-vl:30b": {
          "name": "Qwen Vision-30B"
        }
      }
    },
    "vllm": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "vLLM",
      "options": {
        "baseURL": "$VLLM_API_BASE",
        "apiKey": "local"
      },
      "models": {
        "qwen3-14b-bf16": {
          "name": "Qwen3-14B BF16",
          "limit": {
            "context": 16384,
            "output": 2048
          }
        }
      }
    }
  }
}
JSON

  chmod 600 "$config_path" 2>/dev/null || true
  rm -f "$config_dir/tui.json" >/dev/null 2>&1 || true

  if command_exists python3 && python3 --version >/dev/null 2>&1; then
    python3 -m json.tool "$config_path" >/dev/null ||
      fail "Generated OpenCode configuration is invalid."
  fi

  printf '%s\n' "$config_path"
<<<<<<< HEAD
}
>>>>>>> dffd222 (Add files via upload)
=======
}
>>>>>>> 3ebe8a0 (Add repository attributes and ignore rules)
