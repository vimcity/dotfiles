#!/usr/bin/env bash

set -euo pipefail

export PATH="$HOME/.local/bin:$HOME/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"

if ! command -v pbpaste >/dev/null 2>&1 || ! command -v pbcopy >/dev/null 2>&1; then
    tmux display-message "prompt clean: clipboard tools unavailable"
    exit 0
fi

input_text="$(pbpaste)"

if [[ -z "${input_text//[[:space:]]/}" ]]; then
    tmux display-message "prompt clean: clipboard is empty"
    exit 0
fi

run_fabric_pattern() {
    if command -v fabric-ai >/dev/null 2>&1; then
        env LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 \
            OPENAI_API_BASE="${OPENAI_API_BASE:-http://127.0.0.1:8000/v1}" \
            OPENAI_API_KEY="${OPENAI_API_KEY:-local}" \
            fabric-ai -p voice_to_clean_prompt -V OpenAI \
            -m "${FABRIC_MODEL:-Qwen2.5-Coder-32B-Instruct-4bit}" --thinking=off --suppress-think
        return
    fi

    if [[ -x "$HOME/.local/bin/fabric-ai" ]]; then
        env LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 \
            OPENAI_API_BASE="${OPENAI_API_BASE:-http://127.0.0.1:8000/v1}" \
            OPENAI_API_KEY="${OPENAI_API_KEY:-local}" \
            "$HOME/.local/bin/fabric-ai" -p voice_to_clean_prompt -V OpenAI \
            -m "${FABRIC_MODEL:-Qwen2.5-Coder-32B-Instruct-4bit}" --thinking=off --suppress-think
        return
    fi

    return 127
}

if ! cleaned_text="$(printf '%s' "$input_text" | run_fabric_pattern 2>/dev/null)"; then
    tmux display-message "prompt clean: fabric not available in tmux env"
    exit 0
fi

if [[ -z "${cleaned_text//[[:space:]]/}" ]]; then
    tmux display-message "prompt clean: no output from fabric"
    exit 0
fi

printf '%s' "$cleaned_text" | pbcopy
tmux set-buffer -- "$cleaned_text"

tmux display-message "prompt clean: improved prompt copied to clipboard"

