#!/usr/bin/env bash

set -euo pipefail

export PATH="$HOME/.local/bin:$HOME/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"

command_path="$HOME/dotfiles/bin/anonymize-clipboard"

if [[ ! -x "$command_path" ]]; then
    tmux display-message "anon clip: command not found"
    exit 0
fi

if ! anonymized_text="$("$command_path" 2>/dev/null)"; then
    tmux display-message "anon clip: failed"
    exit 0
fi

if [[ -z "${anonymized_text//[[:space:]]/}" ]]; then
    tmux display-message "anon clip: no output"
    exit 0
fi

tmux set-buffer -- "$anonymized_text"
tmux paste-buffer
tmux display-message "anon clip: copied and pasted"
