#!/usr/bin/env bash

set -euo pipefail

LIMIT="${TMUX_CLIPBOARD_HISTORY_LIMIT:-200}"

if ! command -v fzf >/dev/null 2>&1; then
    tmux display-message "clipboard history: fzf is not installed"
    exit 0
fi

buffers="$(tmux list-buffers -F '#{buffer_name}	#{buffer_size}	#{buffer_sample}' 2>/dev/null || true)"

if [[ -z "$buffers" ]]; then
    tmux display-message "clipboard history: no tmux buffers yet"
    exit 0
fi

selection="$(printf '%s\n' "$buffers" | head -n "$LIMIT" | fzf --reverse --height=100% --layout=reverse --border --prompt='clipboard > ' --header='enter: paste + copy to system clipboard' --delimiter='\t' --with-nth=2,3 --preview='tmux show-buffer -b {1}')"

if [[ -z "$selection" ]]; then
    exit 0
fi

buffer_name="${selection%%$'\t'*}"

tmux paste-buffer -b "$buffer_name"

if command -v pbcopy >/dev/null 2>&1; then
    tmux show-buffer -b "$buffer_name" | pbcopy
fi

tmux display-message "clipboard history: pasted $buffer_name"
