#!/usr/bin/env bash
set -euo pipefail

entrypoint="${1:-}"
case "$entrypoint" in
  shell|jira|posting|btop|yazi|ghprs|quick-ask|org-task|agenda) ;;
  *)
    printf 'unknown tool overlay: %s\n' "$entrypoint" >&2
    exit 2
    ;;
esac

args=(
  plugin pane open
  --plugin "$HERDR_PLUGIN_ID"
  --entrypoint "$entrypoint"
  --placement overlay
  --focus
)

cwd="${HERDR_ACTIVE_PANE_CWD:-}"
if [[ -z "$cwd" && -n "${HERDR_PANE_ID:-}" ]]; then
  cwd="$("${HERDR_BIN_PATH:-herdr}" pane get "$HERDR_PANE_ID" | jq -r '.result.pane.foreground_cwd // .result.pane.cwd // empty' 2>/dev/null || true)"
fi

if [[ -n "$cwd" ]]; then
  args+=(--env "TOOLS_CW=$cwd")
fi

exec "${HERDR_BIN_PATH:-herdr}" "${args[@]}"
