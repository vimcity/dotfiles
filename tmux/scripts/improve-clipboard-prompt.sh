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
    if command -v fabric >/dev/null 2>&1; then
        fabric -p voice_to_clean_prompt
        return
    fi

    if [[ -x "$HOME/.local/bin/fabric" ]]; then
        "$HOME/.local/bin/fabric" -p voice_to_clean_prompt
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
