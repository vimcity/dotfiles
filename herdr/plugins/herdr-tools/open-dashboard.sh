#!/usr/bin/env bash
set -euo pipefail

args=(
  plugin pane open
  --plugin "$HERDR_PLUGIN_ID"
  --entrypoint dashboard
  --placement overlay
  --focus
)

exec "${HERDR_BIN_PATH:-herdr}" "${args[@]}"
