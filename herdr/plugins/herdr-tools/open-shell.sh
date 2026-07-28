#!/usr/bin/env bash
set -euo pipefail

args=(
  plugin pane open
  --plugin "$HERDR_PLUGIN_ID"
  --entrypoint shell
  --placement overlay
  --focus
)

cwd=""
if [[ -n "${HERDR_PANE_ID:-}" ]]; then
  cwd="$("${HERDR_BIN_PATH:-herdr}" pane get "$HERDR_PANE_ID" | jq -r '.result.pane.foreground_cwd // .result.pane.cwd // empty' 2>/dev/null)"
fi

if [[ -n "$cwd" ]]; then
  args+=(--env "TOOLS_CW=$cwd")
fi

exec "${HERDR_BIN_PATH:-herdr}" "${args[@]}"
