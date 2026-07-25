#!/usr/bin/env bash
#
# vim-herdr-navigation — herdr side
#
# Invoked by a herdr keybind as: navigate.sh <left|down|up|right>
#
# If the focused pane is running Vim/Neovim in the foreground, hand the matching
# Ctrl chord to that pane so Vim moves between its own splits (and, at a split
# edge, calls back into herdr to cross the pane boundary — see editor/*). The same
# forwarding can be turned on for other TUIs that own Ctrl+h/j/k/l themselves via
# HERDR_NAV_PASSTHROUGH_RE (off by default — see below). For any other foreground
# process, move herdr's pane focus directly.
#
# Requires `jq`. Without it, detection is skipped and every key just moves the
# herdr pane focus (no Vim awareness).

set -euo pipefail

dir="${1:?usage: navigate.sh <left|down|up|right>}"
herdr="${HERDR_BIN_PATH:-herdr}"
pane="${HERDR_PANE_ID:-}"

case "$dir" in
  left)  key="ctrl+h"; key_text=$'\x08' ;;
  down)  key="ctrl+j"; key_text=$'\x0a' ;;
  up)    key="ctrl+k"; key_text=$'\x0b' ;;
  right) key="ctrl+l"; key_text=$'\x0c' ;;
  *) echo "navigate.sh: unknown direction: $dir" >&2; exit 2 ;;
esac

# Foreground process names that mean "Vim is in control of this pane".
# Same matcher vim-tmux-navigator uses: vi, vim, nvim, view, gvim, *diff, ...
vim_re='^g?(view|l?n?vim?x?)(diff)?$'

# Opt-in passthrough for non-Vim TUIs (see README): HERDR_NAV_PASSTHROUGH_RE is an
# ERE matched against the lower-cased process name. Empty (default) forwards only Vim.
passthrough_re="${HERDR_NAV_PASSTHROUGH_RE:-}"

debug() {
  if [ "${HERDR_NAV_DEBUG:-}" = "1" ]; then
    printf '%s dir=%s pane=%s %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$dir" "${pane:-}" "$*" >>/tmp/herdr-nav.log
  fi
}

if [ -z "$pane" ] && command -v jq >/dev/null 2>&1; then
  pane="$("$herdr" pane current 2>/dev/null | jq -r '.result.pane.pane_id // empty' || true)"
fi
debug "resolved focused pane"

forward=0
if [ -n "$pane" ] && command -v jq >/dev/null 2>&1; then
  process_info="$("$herdr" pane process-info --pane "$pane" 2>/dev/null || true)"
  debug "process-info=${process_info}"
  if printf '%s\n' "$process_info" \
    | jq -e --arg vim "$vim_re" --arg pass "$passthrough_re" \
        '.result.process_info.foreground_processes[]?.name
         | ascii_downcase
         | select(test($vim) or ($pass != "" and (try test($pass) catch false)))' >/dev/null 2>&1; then
    forward=1
  fi
fi

if [ "$forward" -eq 1 ]; then
  debug "forwarding ${key} into pane"
  exec "$herdr" pane send-text "$pane" "$key_text"
else
  if [ -n "$pane" ]; then
    debug "moving herdr focus"
    exec "$herdr" pane focus --direction "$dir" --pane "$pane"
  fi
  debug "moving herdr focus via current fallback"
  exec "$herdr" pane focus --direction "$dir" --current
fi
