#!/usr/bin/env bash
# Read focused Herdr pane scrollback, highlight with tailspin, open in Neovim.
set -euo pipefail

pane_id="${HERDR_ACTIVE_PANE_ID:-${HERDR_PANE_ID:-}}"
if [[ -z "$pane_id" ]]; then
    pane_id="$(herdr pane current 2>/dev/null | jq -r '.result.pane.pane_id // empty')"
fi

if [[ -z "$pane_id" ]]; then
    printf 'herdr/scripts/scrollback-nvim.sh: no pane id\n' >&2
    exit 1
fi

if ! command -v tspin >/dev/null 2>&1; then
    printf 'herdr/scripts/scrollback-nvim.sh: tspin not found\n' >&2
    exit 1
fi

lines="${HERDR_SCROLLBACK_LINES:-10000}"
tmp="$(mktemp "${TMPDIR:-/tmp}/herdr-scrollback.XXXXXX")"
trap 'rm -f "$tmp"' EXIT

herdr pane read "$pane_id" \
    --source recent-unwrapped \
    --lines "$lines" \
    --format text >"$tmp"

tspin -p "$tmp" | "${NVIM_BIN:-nvim}" - \
    -c 'setlocal buftype=nofile nomodifiable nomodified bufhidden=wipe nowrap signcolumn=no' \
    -c 'AnsiEnable'
