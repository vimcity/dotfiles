#!/usr/bin/env bash
# Fuzzy-find a project directory and create or switch to a matching tmux session.
# Usage: tmux-sessionizer.sh [directory]
set -euo pipefail

SEARCH_PATHS=(
  "$HOME/Projects"
  "$HOME/dotfiles"
  "$HOME/Documents"
)

if [[ $# -eq 1 ]]; then
  selected="$1"
else
  if command -v fd >/dev/null 2>&1; then
    selected="$(
      fd --type d --max-depth 1 . "${SEARCH_PATHS[@]}" 2>/dev/null \
        | fzf --prompt='project> ' --height=40% --layout=reverse --border=rounded \
              --header='New or switch project session'
    )" || true
  else
    selected="$(
      find "${SEARCH_PATHS[@]}" -mindepth 1 -maxdepth 1 -type d 2>/dev/null \
        | fzf --prompt='project> ' --height=40% --layout=reverse --border=rounded \
              --header='New or switch project session'
    )" || true
  fi
fi

[[ -z "${selected:-}" ]] && exit 0

selected_name="$(basename "$selected" | tr . _)"
tmux_running="$(pgrep tmux 2>/dev/null || true)"

if [[ -z "${TMUX:-}" && -z "$tmux_running" ]]; then
  tmux new-session -s "$selected_name" -c "$selected"
  exit 0
fi

if ! tmux has-session -t="$selected_name" 2>/dev/null; then
  tmux new-session -ds "$selected_name" -c "$selected"
fi

if [[ -n "${TMUX:-}" ]]; then
  tmux switch-client -t "$selected_name"
else
  tmux attach-session -t "$selected_name"
fi
