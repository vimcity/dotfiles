#!/usr/bin/env bash
set -euo pipefail

projects_dir="${PROJECTS_DIR:-$HOME/Projects}"

if [[ ! -d "$projects_dir" ]]; then
    printf 'Projects directory not found: %s\n' "$projects_dir" >&2
    exit 1
fi

workspace_id="${HERDR_WORKSPACE_ID:-}"
if [[ -z "$workspace_id" ]]; then
    workspace_id="$(herdr workspace list | jq -r '.result.workspaces[0].workspace_id // empty')"
fi

if [[ -z "$workspace_id" ]]; then
    printf 'No Herdr workspace is available\n' >&2
    exit 1
fi

payload="$(herdr tab create --workspace "$workspace_id" --label nvim --cwd "$projects_dir" --focus)"
pane_id="$(printf '%s' "$payload" | jq -r '.result.root_pane.pane_id // empty')"

if [[ -z "$pane_id" ]]; then
    printf 'Herdr did not return a new tab pane\n' >&2
    exit 1
fi

exec herdr pane send-text "$pane_id" $'exec nvim\n'
