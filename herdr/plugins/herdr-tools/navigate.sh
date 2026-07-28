#!/usr/bin/env bash

set -euo pipefail

dir="${1:?usage: navigate.sh <left|down|up|right>}"
herdr="${HERDR_BIN_PATH:-herdr}"
pane="${HERDR_PANE_ID:-}"

case "$dir" in
  left)  key_text=$'\x08' ;;
  down)  key_text=$'\x0a' ;;
  up)    key_text=$'\x0b' ;;
  right) key_text=$'\x0c' ;;
  *) echo "navigate.sh: unknown direction: $dir" >&2; exit 2 ;;
esac

vim_re='^g?(view|l?n?vim?x?)(diff)?$'

if [ -n "$pane" ] && command -v jq >/dev/null 2>&1; then
  process_info="$("$herdr" pane process-info --current 2>/dev/null || true)"
  if printf '%s\n' "$process_info" \
    | jq -e --arg vim "$vim_re" \
      '.result.process_info.foreground_processes[]?.name
       | ascii_downcase
       | select(test($vim))' >/dev/null 2>&1; then
    exec "$herdr" pane send-text "$pane" "$key_text"
  fi
fi

exec "$herdr" pane focus --direction "$dir" --current
