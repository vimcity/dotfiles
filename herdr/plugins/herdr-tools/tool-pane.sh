#!/usr/bin/env bash
set -euo pipefail

tool="${1:-shell}"
cwd="${TOOLS_CW:-$PWD}"

case "$tool" in
  shell)
    cd "$cwd"
    exec "${SHELL:-/bin/zsh}" -l
    ;;
  jira)
    cd "${JIRA_TUI_ROOT:-$HOME/Projects/jira-tui/bin}"
    exec "${JIRA_TUI_BIN:-$HOME/.local/bin/jira-tui}"
    ;;
  posting)
    cd "$cwd"
    exec "${POSTING_BIN:-posting}" --env "$HOME/.local/share/posting/default/posting.env"
    ;;
  btop)
    cd "$cwd"
    exec "${BTOP_BIN:-/opt/homebrew/bin/btop}"
    ;;
  yazi)
    cd "$cwd"
    exec "${YAZI_BIN:-yazi}"
    ;;
  ghprs)
    cd "$HOME"
    exec "$HOME/dotfiles/bin/ghprs" review
    ;;
  quick-ask)
    cd "$cwd"
    exec "$HOME/dotfiles/tmux/scripts/llm-ask.sh"
    ;;
  org-task)
    cd "$HOME/Documents/org"
    exec "$HOME/dotfiles/tmux/scripts/quick-org-task.sh"
    ;;
  agenda)
    cd "$HOME/Documents/org"
    exec "$HOME/dotfiles/tmux/scripts/agenda-today.sh"
    ;;
  *)
    printf 'unknown tool pane: %s\n' "$tool" >&2
    exit 2
  ;;
esac
