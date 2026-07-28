#!/usr/bin/env bash
set -euo pipefail

if [[ "${HERDR_AUTO_RENAME:-1}" == "0" ]]; then
  exit 0
fi

if [[ -z "${HERDR_ENV:-}" || -z "${HERDR_TAB_ID:-}" ]]; then
  exit 0
fi

cwd="${1:-${PWD:-}}"
if [[ -z "$cwd" || ! -d "$cwd" ]]; then
  exit 0
fi

# Persist the last label we generated, rather than just a "seen" sentinel.
# That lets us keep following directory changes until the user chooses a
# different tab name. A manual name is then left alone permanently (unless the
# user renames it back to the bare tab number to opt into auto naming again).
state_dir="${XDG_CACHE_HOME:-$HOME/.cache}/herdr/auto-renamed-tabs-v2"
tab_key="${HERDR_TAB_ID//[^[:alnum:]_.-]/_}"
state_file="$state_dir/$tab_key"

tab_json="$("${HERDR_BIN_PATH:-herdr}" tab get "$HERDR_TAB_ID" 2>/dev/null)" || exit 0
current_label="$(printf '%s' "$tab_json" | jq -r '.result.tab.label // empty' 2>/dev/null)"
workspace_id="$(printf '%s' "$tab_json" | jq -r '.result.tab.workspace_id // empty' 2>/dev/null)"
tabs_json="$("${HERDR_BIN_PATH:-herdr}" tab list 2>/dev/null)" || exit 0
# `tab.number` is a global historical counter. The tab bar should instead show
# the compact 1..N position within this workspace, just like tmux windows.
tab_number="$(printf '%s' "$tabs_json" | jq -r --arg tab "$HERDR_TAB_ID" --arg ws "$workspace_id" '
  .result.tabs
  | map(select(.workspace_id == $ws))
  | to_entries[]
  | select(.value.tab_id == $tab)
  | (.key + 1)
' 2>/dev/null)"
[[ -n "$current_label" && -n "$tab_number" ]] || exit 0

case "$cwd" in
  "$HOME") label="~" ;;
  /) label="/" ;;
  *) label="$(basename "$cwd")" ;;
esac

if [[ -z "$label" ]]; then
  exit 0
fi

auto_label="$tab_number $label"
last_auto_label=""
[[ -f "$state_file" ]] && last_auto_label="$(<"$state_file")"

if [[ -n "$last_auto_label" ]]; then
  if [[ "$current_label" != "$last_auto_label" ]]; then
    # Renaming back to Herdr's default numeric label is the explicit opt-in to
    # auto naming again. Any other different label is user-owned.
    [[ "$current_label" == "$tab_number" ]] || exit 0
  fi
else
  # Migrate the old auto labels ("N dirname") while refusing to overwrite a
  # user-selected label on a tab that predates this script.
  [[ "$current_label" == "$tab_number" || "$current_label" == "$tab_number "* ]] || exit 0
fi

[[ "$current_label" == "$auto_label" ]] && {
  mkdir -p "$state_dir"
  printf '%s\n' "$auto_label" > "$state_file"
  exit 0
}

if "${HERDR_BIN_PATH:-herdr}" tab rename "$HERDR_TAB_ID" "$auto_label" >/dev/null; then
  mkdir -p "$state_dir"
  printf '%s\n' "$auto_label" > "$state_file"
fi
